/// Resultado del primer factor: la contraseña fue correcta y falta el código
/// de la app autenticadora (TOTP), que valida el servidor.
class DesafioMfa {
  const DesafioMfa({
    required this.tokenDesafio,
    required this.venceEn,
    required this.requiereEnrolamiento,
    this.otpauthUri,
    this.secreto,
  });

  /// Token de corta vida (5 min) que acompaña al código. No autentica peticiones.
  final String tokenDesafio;
  final DateTime venceEn;

  /// Primer acceso: hay que vincular la app autenticadora con [otpauthUri].
  final bool requiereEnrolamiento;

  /// `otpauth://totp/...` para abrir la app autenticadora o generar el QR.
  final String? otpauthUri;

  /// La misma semilla en Base32, para captura manual.
  final String? secreto;
}

/// Dónde está abierta la otra sesión cuando el servidor responde `409 sesion_activa`.
class SesionActivaInfo {
  const SesionActivaInfo({required this.canal, required this.dispositivo, this.ultimaActividad});

  factory SesionActivaInfo.desdeDetalles(Map<String, String> detalles) => SesionActivaInfo(
    canal: detalles['canal'] ?? 'WEB',
    dispositivo: detalles['dispositivo'] ?? '',
    ultimaActividad: DateTime.tryParse(detalles['ultimaActividad'] ?? '')?.toLocal(),
  );

  final String canal;
  final String dispositivo;
  final DateTime? ultimaActividad;

  bool get esWeb => canal == 'WEB';

  /// Descripción legible del dispositivo a partir del User-Agent.
  String get descripcionDispositivo {
    final ua = dispositivo.toLowerCase();
    if (ua.contains('dart') || ua.contains('flutter')) {
      return 'App Gesto Pago';
    }
    final navegador = ua.contains('edg/')
        ? 'Edge'
        : ua.contains('chrome/')
        ? 'Chrome'
        : ua.contains('firefox/')
        ? 'Firefox'
        : ua.contains('safari/')
        ? 'Safari'
        : null;
    final sistema = ua.contains('android')
        ? 'Android'
        : (ua.contains('iphone') || ua.contains('ipad'))
        ? 'iOS'
        : ua.contains('mac os')
        ? 'macOS'
        : ua.contains('windows')
        ? 'Windows'
        : ua.contains('linux')
        ? 'Linux'
        : null;
    final partes = [?navegador, ?sistema];
    return partes.isEmpty ? 'Dispositivo desconocido' : partes.join(' en ');
  }
}
