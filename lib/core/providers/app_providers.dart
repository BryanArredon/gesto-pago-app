import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/data/auth_repository_impl.dart';
import '../../features/auth/data/auth_remote.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/catalogo/data/catalogo_repository_impl.dart';
import '../../features/catalogo/data/catalogo_remote.dart';
import '../../features/catalogo/domain/catalogo_repository.dart';
import '../../features/cuenta/data/cuenta_remote.dart';
import '../../features/pagos/data/pagos_repository_impl.dart';
import '../../features/pagos/data/pagos_remote.dart';
import '../../features/pagos/domain/pagos_repository.dart';
import '../../features/registro/data/registro_remote.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';
import '../network/token_refresher.dart';
import '../network/token_store.dart';

final tokenStoreProvider = Provider<TokenStore>(
  (_) => const TokenStore(
    FlutterSecureStorage(
      // Keystore de Android con cifrado AES respaldado por hardware.
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      // Solo legible con el dispositivo desbloqueado y nunca en respaldos de iCloud.
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
    ),
  ),
);

/// Puente mutable que entrega el renovador de sesión a [ApiClient] sin crear
/// una referencia circular estática entre ApiClient y AuthRepository.
final tokenRefresherBridgeProvider = Provider<TokenRefresherBridge>((_) => TokenRefresherBridge());

/// Puente que entrega a [ApiClient] el aviso de sesión perdida sin depender
/// del SessionController (rompe el ciclo ApiClient -> SessionController ->
/// AuthRepository -> ApiClient).
final sessionExpiredBridgeProvider = Provider<SessionExpiredBridge>((_) => SessionExpiredBridge());

ApiClient _cliente(Ref ref, String baseUrl) {
  return ApiClient(
    baseUrl: baseUrl,
    tokenStore: ref.watch(tokenStoreProvider),
    tokenRefresher: ref.watch(tokenRefresherBridgeProvider).resolve,
    onSessionExpired: ref.watch(sessionExpiredBridgeProvider).resolve,
  );
}

/// Cliente HTTP de api-gesto-pago (catálogo y pagos).
final apiClientProvider = Provider<ApiClient>((ref) => _cliente(ref, AppConfig.apiBaseUrl));

/// Cliente HTTP de onboarding-clientes (identidad, sesiones, cuenta y alta).
final onboardingClientProvider = Provider<ApiClient>((ref) => _cliente(ref, AppConfig.onboardingBaseUrl));

final authRepositoryProvider = Provider<AuthRepository>((Ref ref) {
  final client = ref.watch(onboardingClientProvider);
  return AuthRepositoryImpl(AuthRemote(client.dio), ref.watch(tokenStoreProvider));
});

final cuentaRemoteProvider = Provider<CuentaRemote>((ref) {
  return CuentaRemote(ref.watch(onboardingClientProvider).dio);
});

final registroRemoteProvider = Provider<RegistroRemote>((ref) {
  return RegistroRemote(ref.watch(onboardingClientProvider).dio);
});

final catalogoRepositoryProvider = Provider<CatalogoRepository>((ref) {
  return CatalogoRepositoryImpl(CatalogoRemote(ref.watch(apiClientProvider).dio));
});

final pagosRepositoryProvider = Provider<PagosRepository>((ref) {
  return PagosRepositoryImpl(PagosRemote(ref.watch(apiClientProvider).dio));
});

/// Preferencia de tema del usuario (system/light/dark). En memoria por ahora.
final themeModeProvider = StateProvider<ThemeMode>((_) => ThemeMode.system);
