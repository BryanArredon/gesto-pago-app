import 'dart:math';

/// Franquicias o redes de tarjetas de crédito y débito.
enum FranquiciaTarjeta {
  visa,
  mastercard,
  americanExpress,
  carnet,
  discover,
  desconocida,
}

/// Utilidades del algoritmo de Luhn (Módulo 10) conforme a la norma ISO/IEC 7812.
class Luhn {
  const Luhn._();

  static const int longitudCuenta = 10;
  static const int longitudTarjetaEstandar = 16;

  /// Valida si un número cumple con el algoritmo de Luhn (Módulo 10).
  /// Válido para números de cuenta de 10 dígitos o números de tarjeta de 13 a 19 dígitos.
  static bool validar(String? numero) {
    if (numero == null) return false;
    final limpio = numero.replaceAll(RegExp(r'\D'), '');
    if (limpio.length < 2) return false;

    int suma = 0;
    final len = limpio.length;
    for (int i = 0; i < len; i++) {
      int d = int.parse(limpio[i]);
      final duplicar = (len - 1 - i) % 2 == 1;
      if (duplicar) {
        d *= 2;
        if (d > 9) d -= 9;
      }
      suma += d;
    }
    return suma % 10 == 0;
  }

  /// Calcula el dígito verificador Luhn ('0' a '9') necesario para completar una base de dígitos.
  static String calcularDigito(String base) {
    final limpio = base.replaceAll(RegExp(r'\D'), '');
    if (limpio.isEmpty) return '0';

    int suma = 0;
    final len = limpio.length;
    for (int i = 0; i < len; i++) {
      int d = int.parse(limpio[i]);
      final duplicar = (len - 1 - i) % 2 == 0;
      if (duplicar) {
        d *= 2;
        if (d > 9) d -= 9;
      }
      suma += d;
    }
    final digito = (10 - (suma % 10)) % 10;
    return digito.toString();
  }

  /// Genera un número de tarjeta válido según el algoritmo de Luhn.
  static String generarTarjeta({String bin = '453201', int longitud = 16}) {
    final binLimpio = bin.replaceAll(RegExp(r'\D'), '');
    final faltantes = longitud - binLimpio.length - 1;
    if (faltantes < 0) {
      throw ArgumentError('El BIN es más largo que la longitud permitida');
    }

    final random = Random.secure();
    final buffer = StringBuffer(binLimpio);
    for (int i = 0; i < faltantes; i++) {
      buffer.write(random.nextInt(10));
    }

    final base = buffer.toString();
    final verificador = calcularDigito(base);
    return '$base$verificador';
  }

  /// Detecta la franquicia de la tarjeta a partir de su prefijo numérico.
  static FranquiciaTarjeta obtenerFranquicia(String? numero) {
    if (numero == null) return FranquiciaTarjeta.desconocida;
    final limpio = numero.replaceAll(RegExp(r'\D'), '');
    if (limpio.isEmpty) return FranquiciaTarjeta.desconocida;

    if (limpio.startsWith('4')) return FranquiciaTarjeta.visa;
    if (RegExp(r'^(5[1-5]|222[1-9]|22[3-9]\d|2[3-6]\d{2}|27[01]\d|2720)').hasMatch(limpio)) {
      return FranquiciaTarjeta.mastercard;
    }
    if (RegExp(r'^3[47]').hasMatch(limpio)) return FranquiciaTarjeta.americanExpress;
    if (RegExp(r'^(506|636|286)').hasMatch(limpio)) return FranquiciaTarjeta.carnet;
    if (RegExp(r'^(6011|65|64[4-9]|622)').hasMatch(limpio)) return FranquiciaTarjeta.discover;

    return FranquiciaTarjeta.desconocida;
  }

  /// Formatea la tarjeta con espacios legibles cada 4 dígitos (o 4-6-5 para AMEX).
  static String formatearTarjeta(String? numero) {
    if (numero == null) return '';
    final limpio = numero.replaceAll(RegExp(r'\D'), '');
    if (obtenerFranquicia(limpio) == FranquiciaTarjeta.americanExpress && limpio.length == 15) {
      return '${limpio.substring(0, 4)} ${limpio.substring(4, 10)} ${limpio.substring(10)}';
    }
    return limpio.replaceAllMapped(RegExp(r'(\d{4})(?=\d)'), (m) => '${m[1]} ').trim();
  }

  /// Enmascara la tarjeta mostrando únicamente los últimos 4 dígitos.
  static String enmascararTarjeta(String? numero) {
    if (numero == null) return '•••• •••• •••• ••••';
    final limpio = numero.replaceAll(RegExp(r'\D'), '');
    if (limpio.length <= 4) return '••••';
    final ultimos = limpio.substring(limpio.length - 4);
    if (limpio.length == 15) {
      return '•••• •••••• •${ultimos.substring(1)}';
    }
    return '•••• •••• •••• $ultimos';
  }
}

