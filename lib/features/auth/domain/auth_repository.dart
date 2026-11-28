import '../../../core/network/token_refresher.dart';
import 'auth_session.dart';
import 'desafio_mfa.dart';

/// Contrato de autenticación contra onboarding-clientes: contraseña, segundo
/// factor TOTP y una sola sesión vigente entre web y móvil.
abstract interface class AuthRepository implements TokenRefresher {
  /// Primer factor: valida correo y contraseña. No abre sesión.
  Future<DesafioMfa> iniciarSesion({required String email, required String password});

  /// Segundo factor: valida el código TOTP, abre la sesión y la persiste.
  ///
  /// Lanza `ConflictException` con `code == 'sesion_activa'` si hay otra sesión
  /// abierta; repetir con [cerrarSesionAnterior] la cierra y continúa.
  Future<AuthSession> verificarSegundoFactor({
    required DesafioMfa desafio,
    required String codigo,
    required String email,
    bool cerrarSesionAnterior = false,
  });

  /// Recupera la sesión persistida si su token no ha vencido.
  Future<AuthSession?> restoreSession();

  /// Comprueba con el servidor que la sesión sigue vigente (p. ej. al volver
  /// del segundo plano). Un 401 cierra la sesión vía el interceptor.
  Future<void> verificarSesionVigente();

  /// Revoca la sesión en el servidor y limpia el almacenamiento local.
  Future<void> logout();

  /// Limpia los datos locales de sesión.
  Future<void> clearSession();

  /// Guarda el nombre a mostrar (llega después, con los datos del cliente).
  Future<void> guardarNombre(String nombre);
}
