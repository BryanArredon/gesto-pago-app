import '../../../core/network/token_store.dart';
import '../../../core/utils/jwt.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_session.dart';
import '../domain/desafio_mfa.dart';
import 'auth_remote.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._tokenStore, {DateTime Function()? reloj}) : _reloj = reloj ?? DateTime.now;

  final AuthRemote _remote;
  final TokenStore _tokenStore;
  final DateTime Function() _reloj;
  Future<String?>? _renovacionEnCurso;

  @override
  Future<DesafioMfa> iniciarSesion({required String email, required String password}) async {
    final r = await _remote.login(email: email, password: password);
    return DesafioMfa(
      tokenDesafio: r.tokenDesafio,
      venceEn: _reloj().add(Duration(seconds: r.expiraEnSegundos)),
      requiereEnrolamiento: r.estado == 'ENROLAMIENTO_REQUERIDO',
      otpauthUri: r.otpauthUri,
      secreto: r.secreto,
    );
  }

  @override
  Future<AuthSession> verificarSegundoFactor({
    required DesafioMfa desafio,
    required String codigo,
    required String email,
    bool cerrarSesionAnterior = false,
  }) async {
    final r = await _remote.verificarMfa(
      tokenDesafio: desafio.tokenDesafio,
      codigo: codigo,
      cerrarSesionAnterior: cerrarSesionAnterior,
    );
    final correo = (claimsJwt(r.accessToken)['correo'] as String?) ?? email.trim().toLowerCase();
    final session = AuthSession(
      email: correo,
      nombre: '',
      accessToken: r.accessToken,
      expiraEn: _expiracion(r),
      clienteId: r.clienteId,
      usuarioId: r.usuarioId,
      sesionId: r.sesionId,
      rol: r.rol,
    );
    await _persistIgnorandoErrores(session);
    return session;
  }

  @override
  Future<AuthSession?> restoreSession() async {
    final s = await _tokenStore.read();
    if (s == null) {
      // Datos incompletos (p. ej. sesión del esquema anterior): empezar limpio.
      await _tokenStore.clear();
      return null;
    }
    if (!s.expiraEn.isAfter(_reloj())) {
      await _tokenStore.clear();
      return null;
    }
    return AuthSession(
      email: s.email,
      nombre: s.nombre,
      accessToken: s.accessToken,
      expiraEn: s.expiraEn,
      clienteId: s.clienteId,
      usuarioId: s.usuarioId,
      sesionId: s.sesionId,
      rol: s.rol,
    );
  }

  /// Una sola renovación concurrente aunque la pidan los dos clientes HTTP.
  @override
  Future<String?> renovarSesion() {
    final enCurso = _renovacionEnCurso;
    if (enCurso != null) {
      return enCurso;
    }
    final futuro = _renovar();
    _renovacionEnCurso = futuro;
    return futuro.whenComplete(() => _renovacionEnCurso = null);
  }

  Future<String?> _renovar() async {
    final r = await _remote.renovar();
    await _tokenStore.actualizarToken(r.accessToken, _expiracion(r));
    return r.accessToken;
  }

  @override
  Future<void> verificarSesionVigente() => _remote.sesion();

  @override
  Future<void> logout() async {
    try {
      if (await _tokenStore.readAccessToken() != null) {
        await _remote.logout();
      }
    } finally {
      // Aunque el servidor no responda, el dispositivo olvida la sesión; la de
      // servidor vence sola por inactividad.
      await _tokenStore.clear();
    }
  }

  @override
  Future<void> clearSession() => _tokenStore.clear();

  @override
  Future<void> guardarNombre(String nombre) async {
    try {
      await _tokenStore.actualizarNombre(nombre);
    } catch (_) {
      // Dato de presentación: no debe romper nada si el keystore falla.
    }
  }

  DateTime _expiracion(AccesoResponse r) =>
      expiracionJwt(r.accessToken) ?? _reloj().add(Duration(seconds: r.expiresIn));

  /// Persiste la sesión; si el almacenamiento seguro falla (keystore
  /// disponible a medias) NO rompe un login ya autorizado por el servidor: la
  /// sesión sigue activa en memoria. Al reiniciar la app habría que entrar de nuevo.
  Future<void> _persistIgnorandoErrores(AuthSession session) async {
    try {
      await _tokenStore.save(
        SesionGuardada(
          accessToken: session.accessToken,
          expiraEn: session.expiraEn,
          email: session.email,
          nombre: session.nombre,
          clienteId: session.clienteId,
          usuarioId: session.usuarioId,
          sesionId: session.sesionId,
          rol: session.rol,
        ),
      );
    } catch (_) {}
  }
}
