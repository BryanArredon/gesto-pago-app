import 'package:flutter_test/flutter_test.dart';
import 'package:gesto_pago_app/core/format/luhn.dart';

void main() {
  group('Luhn', () {
    test('valida correctamente cuenta bancaria de 10 dígitos', () {
      expect(Luhn.validar('0000000018'), isTrue);
      expect(Luhn.validar('0000000019'), isFalse);
    });

    test('calcula dígito verificador Luhn correctamente', () {
      expect(Luhn.calcularDigito('000000001'), '8');
      expect(Luhn.calcularDigito('7'), '5');
    });

    test('genera números de tarjeta de 16 dígitos válidos según Luhn', () {
      for (int i = 0; i < 20; i++) {
        final pan = Luhn.generarTarjeta(bin: '453201', longitud: 16);
        expect(pan.length, 16);
        expect(pan.startsWith('453201'), isTrue);
        expect(Luhn.validar(pan), isTrue);
        expect(Luhn.obtenerFranquicia(pan), FranquiciaTarjeta.visa);
      }
    });

    test('identifica franquicias correctamente', () {
      expect(Luhn.obtenerFranquicia('4532015112345678'), FranquiciaTarjeta.visa);
      expect(Luhn.obtenerFranquicia('5200123456789010'), FranquiciaTarjeta.mastercard);
      expect(Luhn.obtenerFranquicia('378282246310005'), FranquiciaTarjeta.americanExpress);
      expect(Luhn.obtenerFranquicia('5063011234567890'), FranquiciaTarjeta.carnet);
      expect(Luhn.obtenerFranquicia('6011123456789012'), FranquiciaTarjeta.discover);
    });

    test('formatea y enmascara número de tarjeta', () {
      const pan = '4532015112345678';
      expect(Luhn.formatearTarjeta(pan), '4532 0151 1234 5678');
      expect(Luhn.enmascararTarjeta(pan), '•••• •••• •••• 5678');
    });
  });
}

