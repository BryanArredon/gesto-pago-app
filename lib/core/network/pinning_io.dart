import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// Certificate pinning (MASVS-NETWORK): además de la validación TLS normal,
/// el certificado del servidor debe coincidir con una de las huellas SHA-256
/// configuradas. Un proxy con un certificado emitido por una CA instalada en
/// el dispositivo (ataque MitM) es rechazado.
///
/// Se recomienda fijar dos huellas: la vigente y la de respaldo para la rotación.
void aplicarCertificatePinning(Dio dio, List<String> huellasSha256) {
  if (huellasSha256.isEmpty) {
    return;
  }
  final permitidas = huellasSha256.toSet();
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () => HttpClient()..badCertificateCallback = (_, _, _) => false,
    validateCertificate: (certificado, host, port) {
      if (certificado == null) {
        return false;
      }
      return permitidas.contains(huellaSha256(certificado.der));
    },
  );
}

/// Huella SHA-256 en hexadecimal minúsculo del certificado DER.
String huellaSha256(List<int> der) => sha256.convert(der).toString();
