import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gesto_pago_app/core/format/gp_money.dart';

void main() {
  group('GpMoney.format', () {
    test('formatea con símbolo y separadores', () {
      expect(GpMoney.format('1234.5'), contains('1,234.50'));
      expect(GpMoney.format('1234.5'), startsWith(r'$'));
    });

    test('cero y decimales', () {
      expect(GpMoney.format('0'), contains('0.00'));
    });

    test('valores inválidos pasan tal cual', () {
      expect(GpMoney.format('abc'), 'abc');
    });
  });

  group('GpMoney.sanitizarEntrada', () {
    test('quita caracteres no numéricos', () {
      expect(GpMoney.sanitizarEntrada('abc12.3.4'), '12.34');
    });

    test('convierte coma a punto', () {
      expect(GpMoney.sanitizarEntrada('1,50'), '1.50');
    });
  });

  group('MontoInputFormatter', () {
    test('deja solo un importe válido con máximo 2 decimales', () {
      expect(MontoInputFormatter.limpiar('150.567'), '150.56');
      expect(MontoInputFormatter.limpiar('1,5'), '1.5');
      expect(MontoInputFormatter.limpiar('abc12e3'), '123');
      expect(MontoInputFormatter.limpiar('007'), '7');
      expect(MontoInputFormatter.limpiar('.5'), '0.5');
      expect(MontoInputFormatter.limpiar('12.3.4'), '12.34');
      expect(MontoInputFormatter.limpiar('-20'), '20');
      expect(MontoInputFormatter.limpiar('99999999'), '9999999');
    });

    test('al corregir el texto deja el cursor al final', () {
      final r = const MontoInputFormatter().formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '10.999', selection: TextSelection.collapsed(offset: 6)),
      );
      expect(r.text, '10.99');
      expect(r.selection.baseOffset, 5);
    });
  });
}
