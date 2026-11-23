import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();

  /// URL base de api-gesto-pago (catálogo y pagos). En Android (emulador)
  /// usa `10.0.2.2` apuntando al host.
  static String get apiBaseUrl => _url(const String.fromEnvironment('API_BASE_URL'), 8080);

  /// URL base de onboarding-clientes: identidad (login con 2FA y sesiones),
  /// cuenta bancaria y datos del cliente. Su JWT también autentica en
  /// api-gesto-pago (SSO), así que web y móvil comparten credenciales.
  static String get onboardingBaseUrl => _url(const String.fromEnvironment('ONBOARDING_URL'), 8082);

  /// Huellas SHA-256 (hex, separadas por coma) de los certificados del
  /// servidor aceptados en HTTPS. Vacío = sin pinning (desarrollo por HTTP).
  /// Ejemplo: `--dart-define=CERT_PINS=ab12...,cd34...` (actual + respaldo).
  static List<String> get certificadosFijados =>
      const String.fromEnvironment('CERT_PINS')
          .split(',')
          .map((h) => h.trim().toLowerCase().replaceAll(':', ''))
          .where((h) => h.isNotEmpty)
          .toList(growable: false);

  /// Canal declarado al servidor: una sola sesión vigente entre web y móvil.
  static const String canalSesion = 'MOVIL';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 60);

  /// Margen con el que se renueva el token antes de que expire.
  static const Duration margenRenovacion = Duration(minutes: 2);

  static String _url(String desdeEntorno, int puertoLocal) {
    if (desdeEntorno.isNotEmpty) {
      return desdeEntorno;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:$puertoLocal';
    }
    return 'http://localhost:$puertoLocal';
  }
}
