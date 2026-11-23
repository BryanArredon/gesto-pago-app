import 'dart:convert';

/// Lee los claims de un JWT sin verificar la firma. Solo para datos de
/// presentación (expiración, correo): la autorización la decide el servidor.
Map<String, dynamic> claimsJwt(String token) {
  final partes = token.split('.');
  if (partes.length != 3) {
    return const {};
  }
  try {
    final json = utf8.decode(base64Url.decode(base64Url.normalize(partes[1])));
    final valor = jsonDecode(json);
    return valor is Map<String, dynamic> ? valor : const {};
  } catch (_) {
    return const {};
  }
}

/// Instante de expiración (`exp`) del token, o null si no lo trae.
DateTime? expiracionJwt(String token) {
  final exp = claimsJwt(token)['exp'];
  return exp is num ? DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000, isUtc: true) : null;
}
