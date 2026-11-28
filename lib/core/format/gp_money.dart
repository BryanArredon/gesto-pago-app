import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formateo de cantidades monetarias del app.
abstract final class GpMoney {
  static final NumberFormat _formateador = NumberFormat.currency(
    locale: 'es_MX',
    symbol: r'$',
    decimalDigits: 2,
  );

  /// Convierte la cantidad (siempre string en el dominio) a moneda.
  static String format(String monto) {
    final valor = double.tryParse(monto);
    if (valor == null) {
      return monto;
    }
    return _formateador.format(valor);
  }

  /// Solo dígitos/decimal para entrada en campos de texto.
  static String sanitizarEntrada(String texto) {
    final limpiado = texto.replaceAll(',', '.').replaceAll(RegExp(r'[^0-9.]'), '');
    final partes = limpiado.split('.');
    if (partes.length > 2) {
      return '${partes.first}.${partes.sublist(1).join()}';
    }
    return limpiado;
  }
}

/// Restringe un campo de importe a un monto válido mientras se escribe: solo
/// dígitos, un separador decimal (acepta coma) y como máximo 2 decimales.
class MontoInputFormatter extends TextInputFormatter {
  const MontoInputFormatter({this.maxEnteros = 7});

  final int maxEnteros;

  static String limpiar(String texto, {int maxEnteros = 7}) {
    final t = texto.replaceAll(',', '.').replaceAll(RegExp(r'[^0-9.]'), '');
    final partes = t.split('.');
    var entero = partes.first.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (entero.length > maxEnteros) {
      entero = entero.substring(0, maxEnteros);
    }
    if (partes.length == 1) {
      return entero;
    }
    final decimales = partes.sublist(1).join();
    return '${entero.isEmpty ? '0' : entero}.${decimales.length > 2 ? decimales.substring(0, 2) : decimales}';
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final limpio = limpiar(newValue.text, maxEnteros: maxEnteros);
    if (limpio == newValue.text) {
      return newValue;
    }
    return TextEditingValue(text: limpio, selection: TextSelection.collapsed(offset: limpio.length));
  }
}
