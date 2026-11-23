import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/app_exception.dart';
import '../../../core/network/token_refresher.dart';
import '../../../core/providers/app_providers.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_session.dart';
import '../domain/desafio_mfa.dart';

enum SessionStatus { unknown, authenticated, unauthenticated }

/// Estado de sesión de la aplicación.
class SessionState {
  const SessionState({required this.status, this.session, this.motivoCierre});

  const SessionState.unknown() : this(status: SessionStatus.unknown);
  const SessionState.unauthenticated([MotivoCierre? motivo])
    : this(status: SessionStatus.unauthenticated, motivoCierre: motivo);

  final SessionStatus status;
  final AuthSession? session;

  /// Por qué terminó la última sesión (para explicarlo en el login).
  final MotivoCierre? motivoCierre;

  bool get isAuthenticated => status == SessionStatus.authenticated;
}

/// Controla la sesión: restauración, inicio de sesión en dos pasos, logout y
/// cierre cuando el servidor la invalida (otro dispositivo, inactividad).
class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() {
    return const SessionState.unknown();
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<void> restore() async {
    try {
      final session = await _repository.restoreSession();
      state = session != null && session.isAuthenticated
          ? SessionState(status: SessionStatus.authenticated, session: session)
          : const SessionState.unauthenticated();
    } catch (_) {
      // Si falla la lectura del almacenamiento seguro, limpiar y salir a login:
      // nunca dejar la app atascada en "Restaurando sesión…".
      try {
        await _repository.clearSession();
      } catch (_) {}
      state = const SessionState.unauthenticated();
    }
  }

  /// Paso 1: contraseña. No cambia el estado: aún falta el segundo factor.
  Future<DesafioMfa> iniciarSesion({required String email, required String password}) {
    return _repository.iniciarSesion(email: email, password: password);
  }

  /// Paso 2: código TOTP. Puede lanzar `ConflictException(sesion_activa)`.
  Future<SessionState> verificarSegundoFactor({
    required DesafioMfa desafio,
    required String codigo,
    required String email,
    bool cerrarSesionAnterior = false,
  }) async {
    final session = await _repository.verificarSegundoFactor(
      desafio: desafio,
      codigo: codigo,
      email: email,
      cerrarSesionAnterior: cerrarSesionAnterior,
    );
    state = SessionState(status: SessionStatus.authenticated, session: session);
    return state;
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {
      // El logout local siempre procede; la sesión de servidor vence sola.
    } finally {
      state = const SessionState.unauthenticated(MotivoCierre.manual);
    }
  }

  /// El servidor dio la sesión por perdida (la llama el interceptor HTTP).
  void onSessionExpired([MotivoCierre motivo = MotivoCierre.expirada]) {
    if (state.status != SessionStatus.authenticated) {
      return;
    }
    _repository.clearSession();
    state = SessionState.unauthenticated(motivo);
  }

  /// Al volver del segundo plano: si la sesión se cerró desde la web o venció
  /// mientras la app estaba en pausa, salir de inmediato en vez de mostrar
  /// datos de una sesión inválida.
  Future<void> verificarAlReanudar() async {
    final actual = state.session;
    if (actual == null) {
      return;
    }
    if (!actual.expiraEn.isAfter(DateTime.now()) && await _tokenVencido()) {
      onSessionExpired(MotivoCierre.expirada);
      return;
    }
    try {
      await _repository.verificarSesionVigente();
    } on UnauthorizedException {
      // El interceptor ya cerró la sesión con el motivo que dio el servidor.
    } on AppException {
      // Sin red: se reintentará en la siguiente petición.
    }
  }

  Future<bool> _tokenVencido() async {
    final restaurada = await _repository.restoreSession();
    return restaurada == null;
  }

  void actualizarNombre(String nombre) {
    final actual = state.session;
    if (actual == null || nombre.isEmpty || actual.nombre == nombre) {
      return;
    }
    _repository.guardarNombre(nombre);
    state = SessionState(
      status: state.status,
      session: actual.copyWith(nombre: nombre),
    );
  }
}

final sessionControllerProvider = NotifierProvider<SessionController, SessionState>(SessionController.new);
