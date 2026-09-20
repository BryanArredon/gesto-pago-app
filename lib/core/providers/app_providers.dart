import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/application/session_controller.dart';
import '../../features/auth/data/auth_repository_impl.dart';
import '../../features/auth/data/auth_remote.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/catalogo/data/catalogo_repository_impl.dart';
import '../../features/catalogo/data/catalogo_remote.dart';
import '../../features/catalogo/domain/catalogo_repository.dart';
import '../../features/pagos/data/pagos_repository_impl.dart';
import '../../features/pagos/data/pagos_remote.dart';
import '../../features/pagos/domain/pagos_repository.dart';
import '../../features/persona/data/persona_repository_impl.dart';
import '../../features/persona/data/persona_remote.dart';
import '../../features/persona/domain/persona.dart';
import '../network/api_client.dart';
import '../network/token_refresher.dart';
import '../network/token_store.dart';

final tokenStoreProvider = Provider<TokenStore>(
  (_) => const TokenStore(FlutterSecureStorage()),
);

/// Puente mutable que entrega el refresher de sesión a [ApiClient] sin crear
/// una referencia circular estática entre ApiClient y AuthRepository.
final tokenRefresherBridgeProvider = Provider<TokenRefresherBridge>(
  (_) => TokenRefresherBridge(),
);

/// Cliente HTTP compartido. El refresher se resuelve solo frente a un 401
/// (ver [TokenRefresherBridge]) para evitar dependencia circular.
final apiClientProvider = Provider<ApiClient>((Ref ref) {
  final tokenStore = ref.watch(tokenStoreProvider);
  final sessionController = ref.watch(sessionControllerProvider.notifier);
  final bridge = ref.watch(tokenRefresherBridgeProvider);
  return ApiClient(
    tokenStore: tokenStore,
    tokenRefresher: bridge.resolve,
    onSessionExpired: sessionController.onSessionExpired,
  );
});

final authRepositoryProvider = Provider<AuthRepository>((Ref ref) {
  final client = ref.watch(apiClientProvider);
  return AuthRepositoryImpl(AuthRemote(client.dio), ref.watch(tokenStoreProvider));
});

final catalogoRepositoryProvider = Provider<CatalogoRepository>((ref) {
  return CatalogoRepositoryImpl(CatalogoRemote(ref.watch(apiClientProvider).dio));
});

final pagosRepositoryProvider = Provider<PagosRepository>((ref) {
  return PagosRepositoryImpl(PagosRemote(ref.watch(apiClientProvider).dio));
});

final personaRepositoryProvider = Provider<PersonaRepository>((ref) {
  return PersonaRepositoryImpl(PersonaRemote(ref.watch(apiClientProvider).dio));
});

/// Preferencia de tema del usuario (system/light/dark). En memoria por ahora.
final themeModeProvider = StateProvider<ThemeMode>((_) => ThemeMode.system);