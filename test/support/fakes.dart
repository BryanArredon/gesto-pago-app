import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gesto_pago_app/core/network/app_exception.dart';
import 'package:gesto_pago_app/features/auth/domain/auth_repository.dart';
import 'package:gesto_pago_app/features/auth/domain/auth_session.dart';
import 'package:gesto_pago_app/features/auth/domain/desafio_mfa.dart';

/// Almacenamiento seguro en memoria (sin canal de plataforma).
class FakeSecureStorage implements FlutterSecureStorage {
  final Map<String, String> valores = {};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => valores[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      valores.remove(key);
    } else {
      valores[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    valores.remove(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AuthSession sesionDePrueba({DateTime? expiraEn}) => AuthSession(
  email: 'ana@e2e.mx',
  nombre: 'Ana',
  accessToken: 'tok',
  expiraEn: expiraEn ?? DateTime.now().add(const Duration(minutes: 10)),
  clienteId: 'c-1',
  usuarioId: 'u-1',
  sesionId: 's-1',
  rol: 'CLIENTE',
);

DesafioMfa desafioDePrueba({bool enrolamiento = false}) => DesafioMfa(
  tokenDesafio: 'desafio',
  venceEn: DateTime.now().add(const Duration(minutes: 5)),
  requiereEnrolamiento: enrolamiento,
  otpauthUri: enrolamiento ? 'otpauth://totp/Gesto%20Pago:ana@e2e.mx?secret=JBSWY3DPEHPK3PXP' : null,
  secreto: enrolamiento ? 'JBSWY3DPEHPK3PXP' : null,
);

/// Repositorio configurable que registra las llamadas.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.session, this.restoreError, this.logoutError});

  AuthSession? session;
  final Object? restoreError;
  final Object? logoutError;

  /// Errores a lanzar en orden en verificarSegundoFactor (luego tiene éxito).
  final List<AppException> erroresVerificacion = [];
  final List<bool> llamadasVerificacion = [];
  bool clearCalled = false;
  bool logoutCalled = false;

  @override
  Future<AuthSession?> restoreSession() async {
    if (restoreError != null) {
      throw restoreError!;
    }
    return session;
  }

  @override
  Future<DesafioMfa> iniciarSesion({required String email, required String password}) async => desafioDePrueba();

  @override
  Future<AuthSession> verificarSegundoFactor({
    required DesafioMfa desafio,
    required String codigo,
    required String email,
    bool cerrarSesionAnterior = false,
  }) async {
    llamadasVerificacion.add(cerrarSesionAnterior);
    if (erroresVerificacion.isNotEmpty) {
      throw erroresVerificacion.removeAt(0);
    }
    return session = sesionDePrueba();
  }

  @override
  Future<String?> renovarSesion() async => 'renovado';

  @override
  Future<void> verificarSesionVigente() async {}

  @override
  Future<void> logout() async {
    logoutCalled = true;
    if (logoutError != null) {
      throw logoutError!;
    }
  }

  @override
  Future<void> clearSession() async {
    clearCalled = true;
  }

  @override
  Future<void> guardarNombre(String nombre) async {}
}
