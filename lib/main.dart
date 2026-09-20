import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/providers/app_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  // Vincula el refresher de sesión una sola vez: evita la referencia circular
  // estática ApiClient <-> AuthRepository.
  container.read(tokenRefresherBridgeProvider).bind(
        () => container.read(authRepositoryProvider),
      );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const GestoPagoApp(),
    ),
  );
}