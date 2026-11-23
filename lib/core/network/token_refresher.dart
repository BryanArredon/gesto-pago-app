/// Motivo por el que terminó la sesión; la pantalla de login lo explica.
enum MotivoCierre {
  /// El usuario cerró sesión.
  manual,

  /// Venció por inactividad o duración máxima.
  expirada,

  /// Se inició sesión en otro dispositivo (web) y esta se cerró.
  revocada,
}

/// Renueva el token de acceso sobre la sesión vigente del servidor. Lo
/// implementa el repositorio de autenticación; el interceptor HTTP lo usa
/// sin depender de él directamente (evita dependencias circulares).
abstract class TokenRefresher {
  /// Nuevo token de acceso, o null si la sesión ya no es válida.
  Future<String?> renovarSesion();
}

/// Puente que entrega el [TokenRefresher] activo sin crear una referencia
/// circular estática entre ApiClient y AuthRepository. Se vincula una sola
/// vez al arrancar la aplicación.
class TokenRefresherBridge {
  TokenRefresher Function()? _lookup;

  void bind(TokenRefresher Function() lookup) {
    _lookup = lookup;
  }

  TokenRefresher resolve() {
    final lookup = _lookup;
    if (lookup == null) {
      throw StateError('TokenRefresherBridge no ha sido inicializado.');
    }
    return lookup();
  }
}

/// Puente para notificar el fin de la sesión sin que [ApiClient] dependa del
/// SessionController (mismo patrón anti-circular que [TokenRefresherBridge]).
class SessionExpiredBridge {
  void Function(MotivoCierre motivo)? _lookup;

  void bind(void Function(MotivoCierre motivo) lookup) {
    _lookup = lookup;
  }

  void resolve(MotivoCierre motivo) {
    _lookup?.call(motivo);
  }
}
