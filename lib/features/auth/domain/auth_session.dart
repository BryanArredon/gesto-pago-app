/// Sesión autenticada (con segundo factor) en memoria de la aplicación.
///
/// Corresponde a una sesión de servidor en onboarding-clientes ([sesionId]):
/// si se cierra desde la web, o vence por inactividad, el token deja de
/// servir en todos los servicios.
class AuthSession {
  const AuthSession({
    required this.email,
    required this.nombre,
    required this.accessToken,
    required this.expiraEn,
    required this.clienteId,
    required this.usuarioId,
    required this.sesionId,
    required this.rol,
  });

  final String email;
  final String nombre;
  final String accessToken;
  final DateTime expiraEn;
  final String clienteId;
  final String usuarioId;
  final String sesionId;
  final String rol;

  bool get isAuthenticated => accessToken.isNotEmpty;

  bool get esAdministrador => rol == 'ADMIN';

  AuthSession copyWith({String? nombre, String? accessToken, DateTime? expiraEn}) => AuthSession(
    email: email,
    nombre: nombre ?? this.nombre,
    accessToken: accessToken ?? this.accessToken,
    expiraEn: expiraEn ?? this.expiraEn,
    clienteId: clienteId,
    usuarioId: usuarioId,
    sesionId: sesionId,
    rol: rol,
  );
}
