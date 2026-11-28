import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Datos de la sesión persistidos en el almacenamiento seguro del dispositivo
/// (Keychain / Keystore), nunca en preferencias planas (MASVS-STORAGE).
///
/// No hay refresh token: la sesión vive en el servidor y el token de acceso se
/// renueva sobre ella mientras siga vigente.
class SesionGuardada {
  const SesionGuardada({
    required this.accessToken,
    required this.expiraEn,
    required this.email,
    required this.nombre,
    required this.clienteId,
    required this.usuarioId,
    required this.sesionId,
    required this.rol,
  });

  final String accessToken;
  final DateTime expiraEn;
  final String email;
  final String nombre;
  final String clienteId;
  final String usuarioId;
  final String sesionId;
  final String rol;
}

class TokenStore {
  const TokenStore(this._storage);

  static const _keyAccessToken = 'access_token';
  static const _keyExpiraEn = 'session_expira_en';
  static const _keyNombre = 'session_nombre';
  static const _keyEmail = 'session_email';
  static const _keyClienteId = 'session_cliente_id';
  static const _keyUsuarioId = 'session_usuario_id';
  static const _keySesionId = 'session_id';
  static const _keyRol = 'session_rol';
  // Clave del esquema anterior (login propio de api-gesto-pago); se borra al limpiar.
  static const _keyRefreshLegado = 'refresh_token';

  static const _todas = [
    _keyAccessToken,
    _keyExpiraEn,
    _keyNombre,
    _keyEmail,
    _keyClienteId,
    _keyUsuarioId,
    _keySesionId,
    _keyRol,
    _keyRefreshLegado,
  ];

  final FlutterSecureStorage _storage;

  Future<void> save(SesionGuardada s) async {
    await _storage.write(key: _keyAccessToken, value: s.accessToken);
    await _storage.write(key: _keyExpiraEn, value: s.expiraEn.toUtc().toIso8601String());
    await _storage.write(key: _keyNombre, value: s.nombre);
    await _storage.write(key: _keyEmail, value: s.email);
    await _storage.write(key: _keyClienteId, value: s.clienteId);
    await _storage.write(key: _keyUsuarioId, value: s.usuarioId);
    await _storage.write(key: _keySesionId, value: s.sesionId);
    await _storage.write(key: _keyRol, value: s.rol);
  }

  /// Sustituye solo el token tras una renovación.
  Future<void> actualizarToken(String accessToken, DateTime expiraEn) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyExpiraEn, value: expiraEn.toUtc().toIso8601String());
  }

  Future<void> actualizarNombre(String nombre) => _storage.write(key: _keyNombre, value: nombre);

  Future<String?> readAccessToken() => _storage.read(key: _keyAccessToken);

  Future<DateTime?> readExpiraEn() async {
    final valor = await _storage.read(key: _keyExpiraEn);
    return valor == null ? null : DateTime.tryParse(valor);
  }

  /// Sesión completa, o null si falta algún dato (p. ej. sesión del esquema anterior).
  Future<SesionGuardada?> read() async {
    final token = await readAccessToken();
    final expira = await readExpiraEn();
    final email = await _storage.read(key: _keyEmail);
    final clienteId = await _storage.read(key: _keyClienteId);
    final usuarioId = await _storage.read(key: _keyUsuarioId);
    final sesionId = await _storage.read(key: _keySesionId);
    if (token == null ||
        expira == null ||
        email == null ||
        clienteId == null ||
        usuarioId == null ||
        sesionId == null) {
      return null;
    }
    return SesionGuardada(
      accessToken: token,
      expiraEn: expira,
      email: email,
      nombre: await _storage.read(key: _keyNombre) ?? '',
      clienteId: clienteId,
      usuarioId: usuarioId,
      sesionId: sesionId,
      rol: await _storage.read(key: _keyRol) ?? 'CLIENTE',
    );
  }

  Future<void> clear() async {
    for (final key in _todas) {
      await _storage.delete(key: key);
    }
  }
}
