import 'package:dio/dio.dart';

/// En web no es posible fijar certificados desde la app; el navegador valida TLS.
void aplicarCertificatePinning(Dio dio, List<String> huellasSha256) {}
