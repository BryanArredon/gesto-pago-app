import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gesto_pago_app/core/network/token_refresher.dart';
import 'package:gesto_pago_app/core/providers/app_providers.dart';
import 'package:gesto_pago_app/features/auth/application/session_controller.dart';

import '../../support/fakes.dart';

void main() {
  (ProviderContainer, FakeAuthRepository) crear({Object? restoreError, Object? logoutError, bool conSesion = false}) {
    final repo = FakeAuthRepository(
      session: conSesion ? sesionDePrueba() : null,
      restoreError: restoreError,
      logoutError: logoutError,
    );
    final container = ProviderContainer(overrides: [authRepositoryProvider.overrideWithValue(repo)]);
    addTearDown(container.dispose);
    return (container, repo);
  }

  SessionController controller(ProviderContainer c) => c.read(sessionControllerProvider.notifier);

  test('restore sin sesión persistida -> unauthenticated', () async {
    final (c, _) = crear();
    expect(c.read(sessionControllerProvider).status, SessionStatus.unknown);

    await controller(c).restore();

    expect(c.read(sessionControllerProvider).status, SessionStatus.unauthenticated);
  });

  test('restore con sesión persistida -> authenticated', () async {
    final (c, _) = crear(conSesion: true);

    await controller(c).restore();

    final state = c.read(sessionControllerProvider);
    expect(state.status, SessionStatus.authenticated);
    expect(state.session?.sesionId, 's-1');
  });

  test('restore con fallo del almacenamiento seguro -> unauthenticated y limpia', () async {
    final (c, repo) = crear(restoreError: StateError('keystore caído'));

    await controller(c).restore();

    expect(c.read(sessionControllerProvider).status, SessionStatus.unauthenticated);
    expect(repo.clearCalled, isTrue);
  });

  test('la contraseña sola no autentica: solo el segundo factor abre la sesión', () async {
    final (c, _) = crear();
    await controller(c).restore();

    final desafio = await controller(c).iniciarSesion(email: 'ana@e2e.mx', password: 'Segura123!');
    expect(c.read(sessionControllerProvider).status, SessionStatus.unauthenticated);

    await controller(c).verificarSegundoFactor(desafio: desafio, codigo: '123456', email: 'ana@e2e.mx');
    expect(c.read(sessionControllerProvider).status, SessionStatus.authenticated);
  });

  test('sesión revocada desde la web -> unauthenticated con motivo revocada', () async {
    final (c, repo) = crear(conSesion: true);
    await controller(c).restore();

    controller(c).onSessionExpired(MotivoCierre.revocada);

    final state = c.read(sessionControllerProvider);
    expect(state.status, SessionStatus.unauthenticated);
    expect(state.motivoCierre, MotivoCierre.revocada);
    expect(repo.clearCalled, isTrue);
  });

  test('un aviso de expiración sin sesión activa no cambia el motivo mostrado', () async {
    final (c, _) = crear(conSesion: true);
    await controller(c).restore();
    await controller(c).logout();

    controller(c).onSessionExpired(MotivoCierre.expirada);

    expect(c.read(sessionControllerProvider).motivoCierre, MotivoCierre.manual);
  });

  test('logout cierra localmente aunque el servidor falle', () async {
    final (c, repo) = crear(conSesion: true, logoutError: Exception('sin red'));
    await controller(c).restore();

    await controller(c).logout();

    expect(repo.logoutCalled, isTrue);
    expect(c.read(sessionControllerProvider).status, SessionStatus.unauthenticated);
    expect(c.read(sessionControllerProvider).motivoCierre, MotivoCierre.manual);
  });
}
