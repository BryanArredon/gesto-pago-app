import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/notificaciones/notificador_local.dart';
import 'core/notificaciones/notificador_sistema.dart';
import 'core/providers/app_providers.dart';
import 'core/router/app_router.dart';
import 'features/auth/application/session_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Avisos nativos solo en el celular; en web y escritorio queda el inactivo.
  final notificador =
      !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)
      ? NotificadorLocal()
      : const NotificadorInactivo();

  final container = ProviderContainer(
    overrides: [notificadorSistemaProvider.overrideWithValue(notificador)],
  );
  // Vincula los puentes de red una sola vez: evita las referencias circulares
  // estáticas entre ApiClient y AuthRepository/SessionController.
  container
      .read(tokenRefresherBridgeProvider)
      .bind(() => container.read(authRepositoryProvider));
  container
      .read(sessionExpiredBridgeProvider)
      .bind(
        (motivo) => container
            .read(sessionControllerProvider.notifier)
            .onSessionExpired(motivo),
      );

  // Tocar un aviso abre su comprobante o la bandeja; si no hay sesión, el router lleva al login.
  try {
    await notificador.inicializar(
      alTocar: (ruta) => container.read(appRouterProvider).push(ruta),
    );
  } catch (e) {
    // Sin avisos la app funciona igual: nunca bloquear el arranque por esto.
    debugPrint('No se pudieron inicializar los avisos: $e');
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const GestoPagoApp(),
    ),
  );
}
