import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import 'app_exception.dart';
import 'pinning.dart';
import 'token_refresher.dart';
import 'token_store.dart';

/// Cliente HTTP de un servicio (onboarding-clientes o api-gesto-pago).
///
/// Se encarga de: base URL y timeouts, certificate pinning, adjuntar y
/// renovar el token de acceso, cerrar la sesión cuando el servidor la da por
/// perdida y traducir errores a [AppException] tipadas.
class ApiClient {
  ApiClient({
    required String baseUrl,
    required TokenStore tokenStore,
    required TokenRefresher Function() tokenRefresher,
    void Function(MotivoCierre motivo)? onSessionExpired,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.connectTimeout,
        headers: const {'Accept': 'application/json'},
        contentType: Headers.jsonContentType,
      ),
    );
    aplicarCertificatePinning(_dio, AppConfig.certificadosFijados);
    _dio.interceptors.addAll([
      if (kDebugMode)
        LogInterceptor(
          request: true,
          requestHeader: false,
          // Nunca registrar cuerpos: contienen contraseñas, códigos 2FA y PIN.
          requestBody: false,
          responseBody: false,
          responseHeader: false,
          error: true,
          logPrint: (object) => debugPrint('DIO: $object'),
        ),
      AuthInterceptor(
        tokenStore: tokenStore,
        tokenRefresher: tokenRefresher,
        onSessionLost: (motivo) => onSessionExpired?.call(motivo),
      ),
      _ErrorInterceptor(),
    ]);
  }

  late final Dio _dio;

  Dio get dio => _dio;

  /// Convierte cualquier error que salga de la capa HTTP a una [AppException].
  ///
  /// Dio 5.11 envuelve en un [DioException] (con el original en `error`) todo
  /// lo que lanzan los interceptores, así que una [AppException] lanzada en el
  /// interceptor nunca llega sola al caller: aquí se desempaqueta.
  static AppException unwrap(Object error) {
    if (error is AppException) {
      return error;
    }
    if (error is DioException) {
      final inner = error.error;
      if (inner is AppException) {
        return inner;
      }
      return _ErrorInterceptor.map(error);
    }
    return const ApiException('Error inesperado.');
  }
}

/// Adjunta el token y lo renueva antes de que expire (una sola renovación
/// concurrente). No reintenta tras un 401: si el servidor dice que la sesión
/// se perdió (revocada desde otro canal o vencida) se cierra aquí.
///
/// Es un [Interceptor] y no un `QueuedInterceptor` a propósito: la renovación
/// ocurre dentro de [onRequest] y su propia petición (`/auth/renovar`) pasa
/// por este interceptor; con una cola quedaría esperando a la petición que la
/// disparó (deadlock). La exclusión mutua la da [_renovarUnaVez].
@visibleForTesting
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.tokenStore,
    required this.tokenRefresher,
    required this.onSessionLost,
    DateTime Function()? reloj,
  }) : _reloj = reloj ?? DateTime.now;

  final TokenStore tokenStore;
  final TokenRefresher Function() tokenRefresher;
  final void Function(MotivoCierre motivo) onSessionLost;
  final DateTime Function() _reloj;

  Future<String?>? _renovacionEnCurso;

  /// Endpoints que no llevan token: el login en dos pasos.
  static const _publicos = {'/auth/login', '/auth/mfa/verificar', '/clientes'};

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (_esPublico(options)) {
      return handler.next(options);
    }
    var access = await tokenStore.readAccessToken();
    final expira = await tokenStore.readExpiraEn();
    if (access != null &&
        expira != null &&
        options.path != '/auth/renovar' &&
        // Un sondeo pasivo no renueva: renovar cuenta como actividad.
        !options.headers.containsKey(AppConfig.cabeceraConsultaPasiva) &&
        expira.difference(_reloj()) < AppConfig.margenRenovacion) {
      access = await _renovarUnaVez() ?? access;
    }
    if (access != null) {
      options.headers['Authorization'] = 'Bearer $access';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final tieneToken = err.requestOptions.headers.containsKey('Authorization');
    if (err.response?.statusCode == 401 && tieneToken) {
      final code = _codigo(err.response?.data);
      if (UnauthorizedException.esPerdidaDeSesion(code)) {
        await tokenStore.clear();
        onSessionLost(code == 'sesion_revocada' ? MotivoCierre.revocada : MotivoCierre.expirada);
      }
    }
    handler.next(err);
  }

  bool _esPublico(RequestOptions options) {
    // POST /clientes es el alta pública; GET/PUT/DELETE de /clientes sí llevan token.
    if (options.path == '/clientes') {
      return options.method.toUpperCase() == 'POST';
    }
    return _publicos.contains(options.path);
  }

  Future<String?> _renovarUnaVez() {
    final enCurso = _renovacionEnCurso;
    if (enCurso != null) {
      return enCurso;
    }
    final futuro = _renovar();
    _renovacionEnCurso = futuro;
    return futuro.whenComplete(() => _renovacionEnCurso = null);
  }

  Future<String?> _renovar() async {
    try {
      return await tokenRefresher().renovarSesion();
    } catch (_) {
      // Si la renovación falla se envía el token actual: si ya no sirve, el
      // servidor responde 401 y la sesión se cierra en onError.
      return null;
    }
  }

  static String? _codigo(Object? data) {
    if (data is Map) {
      final code = data['codigo'] ?? data['code'];
      return code is String ? code : null;
    }
    return null;
  }
}

/// Traduce errores de [DioException] a excepciones tipadas de la aplicación.
///
/// Acepta los dos formatos del backend: ProblemDetail RFC 9457 de
/// onboarding-clientes (`codigo`, `detail`, `detalles`) y el de api-gesto-pago
/// (`code`, `message`).
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    throw map(err);
  }

  static AppException map(DioException err) {
    final status = err.response?.statusCode;
    final data = err.response?.data;

    String? code;
    var detail = '';
    var detalles = const <String, String>{};
    if (data is Map) {
      final c = data['codigo'] ?? data['code'];
      code = c is String ? c : null;
      final m = data['detail'] ?? data['message'];
      detail = m is String ? m : '';
      final d = data['detalles'];
      if (d is Map) {
        detalles = {for (final e in d.entries) '${e.key}': '${e.value}'};
      }
    }

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const TimeoutException('Espera de respuesta agotada.');
      case DioExceptionType.badCertificate:
        // Certificado que no coincide con el pin: posible intercepción (MitM).
        return const NetworkException('Conexión no segura con el servidor.');
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
      case DioExceptionType.cancel:
        return const NetworkException('Sin conexión con el servidor.');
      case DioExceptionType.badResponse:
        return _mapResponse(status, detail, code, detalles);
    }
  }

  static AppException _mapResponse(int? status, String message, String? code, Map<String, String> detalles) {
    switch (status) {
      case 400:
      case 422:
        return ApiException(message.isEmpty ? 'Solicitud inválida.' : message, code: code, statusCode: status);
      case 401:
        return UnauthorizedException(message.isEmpty ? 'No autorizado.' : message, code: code, statusCode: status);
      case 403:
        return ForbiddenException(message.isEmpty ? 'Sin permisos.' : message, code: code, statusCode: status);
      case 404:
        return NotFoundException(message, code: code, statusCode: status);
      case 409:
        return ConflictException(
          message.isEmpty ? 'Conflicto con el estado actual.' : message,
          code: code,
          statusCode: status,
          detalles: detalles,
        );
      case 423:
        return LockedException(message.isEmpty ? 'Bloqueado temporalmente.' : message, code: code, statusCode: status);
      case 429:
        return RateLimitException(message.isEmpty ? 'Demasiadas peticiones.' : message, code: code, statusCode: status);
      default:
        return ServerException(message.isEmpty ? 'Error del servidor.' : message, statusCode: status);
    }
  }
}
