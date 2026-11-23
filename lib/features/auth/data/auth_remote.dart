import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/app_exception.dart';

/// Respuesta de `POST /auth/login` (primer factor).
class DesafioResponse {
  const DesafioResponse({
    required this.estado,
    required this.tokenDesafio,
    required this.expiraEnSegundos,
    this.otpauthUri,
    this.secreto,
  });

  factory DesafioResponse.fromJson(Map<String, dynamic> json) {
    final token = json['tokenDesafio'];
    final estado = json['estado'];
    if (token is! String || estado is! String) {
      throw const SerializationException('Respuesta de inicio de sesión inválida.');
    }
    return DesafioResponse(
      estado: estado,
      tokenDesafio: token,
      expiraEnSegundos: (json['expiraEnSegundos'] as num?)?.toInt() ?? 300,
      otpauthUri: json['otpauthUri'] as String?,
      secreto: json['secreto'] as String?,
    );
  }

  final String estado;
  final String tokenDesafio;
  final int expiraEnSegundos;
  final String? otpauthUri;
  final String? secreto;
}

/// Respuesta de `POST /auth/mfa/verificar` y `POST /auth/renovar`.
class AccesoResponse {
  const AccesoResponse({
    required this.accessToken,
    required this.expiresIn,
    required this.clienteId,
    required this.usuarioId,
    required this.sesionId,
    required this.rol,
  });

  factory AccesoResponse.fromJson(Map<String, dynamic> json) {
    final token = json['accessToken'];
    final clienteId = json['clienteId'];
    final usuarioId = json['usuarioId'];
    final sesionId = json['sesionId'];
    if (token is! String || clienteId is! String || usuarioId is! String || sesionId is! String) {
      throw const SerializationException('Respuesta de sesión inválida.');
    }
    return AccesoResponse(
      accessToken: token,
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 900,
      clienteId: clienteId,
      usuarioId: usuarioId,
      sesionId: sesionId,
      rol: json['rol'] as String? ?? 'CLIENTE',
    );
  }

  final String accessToken;
  final int expiresIn;
  final String clienteId;
  final String usuarioId;
  final String sesionId;
  final String rol;
}

/// Llamadas de autenticación contra onboarding-clientes.
class AuthRemote {
  AuthRemote(this._dio);

  final Dio _dio;

  Future<DesafioResponse> login({required String email, required String password}) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'correo': email.trim().toLowerCase(), 'contrasenia': password, 'canal': AppConfig.canalSesion},
      );
      return DesafioResponse.fromJson(_mapJson(response.data));
    } catch (e) {
      throw ApiClient.unwrap(e);
    }
  }

  Future<AccesoResponse> verificarMfa({
    required String tokenDesafio,
    required String codigo,
    required bool cerrarSesionAnterior,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/mfa/verificar',
        data: {'tokenDesafio': tokenDesafio, 'codigo': codigo, 'cerrarSesionAnterior': cerrarSesionAnterior},
      );
      return AccesoResponse.fromJson(_mapJson(response.data));
    } catch (e) {
      throw ApiClient.unwrap(e);
    }
  }

  Future<AccesoResponse> renovar() async {
    try {
      final response = await _dio.post('/auth/renovar');
      return AccesoResponse.fromJson(_mapJson(response.data));
    } catch (e) {
      throw ApiClient.unwrap(e);
    }
  }

  Future<void> sesion() async {
    try {
      await _dio.post<void>('/auth/sesion');
    } catch (e) {
      throw ApiClient.unwrap(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post<void>('/auth/logout');
    } catch (e) {
      throw ApiClient.unwrap(e);
    }
  }

  /// Si el servidor respondió algo que no es un objeto JSON (HTML de un proxy,
  /// texto) se lanza una [SerializationException] tipada y no un TypeError.
  static Map<String, dynamic> _mapJson(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw const SerializationException('Respuesta del servidor inválida.');
  }
}
