import 'package:flutter_test/flutter_test.dart';

import 'package:gesto_pago_app/features/registro/domain/solicitud_registro.dart';
import 'package:gesto_pago_app/features/registro/domain/validaciones_onboarding.dart';

void main() {
  final hoy = DateTime(2026, 11, 22);
  final nacimiento = DateTime(1995, 5, 15);

  group('Nombres', () {
    test('solo letras y espacios, 2 a 50 caracteres', () {
      expect(ValidacionesOnboarding.nombre('José María'), isNull);
      expect(ValidacionesOnboarding.nombre('J4'), ErrorCampo.nombreInvalido);
      expect(ValidacionesOnboarding.nombre('A'), ErrorCampo.nombreInvalido);
      expect(ValidacionesOnboarding.nombre(''), ErrorCampo.obligatorio);
      expect(ValidacionesOnboarding.nombre('', opcional: true), isNull);
    });
  });

  group('Mayoría de edad', () {
    test('18 años cumplidos hoy es válido; un día antes no', () {
      expect(ValidacionesOnboarding.fechaNacimiento(DateTime(2008, 11, 22), hoy), isNull);
      expect(ValidacionesOnboarding.fechaNacimiento(DateTime(2008, 11, 23), hoy), ErrorCampo.menorDeEdad);
      expect(ValidacionesOnboarding.fechaNacimiento(DateTime(2027, 1, 1), hoy), ErrorCampo.fechaFutura);
      expect(ValidacionesOnboarding.fechaNacimiento(null, hoy), ErrorCampo.obligatorio);
    });
  });

  group('CURP y RFC', () {
    test('formato oficial', () {
      expect(ValidacionesOnboarding.curp('MAGJ950515HDFRRN01', nacimiento), isNull);
      expect(ValidacionesOnboarding.curp('MAGJ950515', nacimiento), ErrorCampo.curpInvalida);
      expect(ValidacionesOnboarding.rfc('MAGJ950515ABC', nacimiento), isNull);
      expect(ValidacionesOnboarding.rfc('MAG950515AB', nacimiento), ErrorCampo.rfcInvalido);
    });

    test('la fecha AAMMDD embebida debe coincidir con la de nacimiento', () {
      final otraFecha = DateTime(1995, 5, 16);
      expect(ValidacionesOnboarding.curp('MAGJ950515HDFRRN01', otraFecha), ErrorCampo.curpNoCoincideFecha);
      expect(ValidacionesOnboarding.rfc('MAGJ950515ABC', otraFecha), ErrorCampo.rfcNoCoincideFecha);
    });

    test('acepta minúsculas (se normalizan a mayúsculas)', () {
      expect(ValidacionesOnboarding.curp('magj950515hdfrrn01', nacimiento), isNull);
    });
  });

  group('Contacto y domicilio', () {
    test('teléfono de 10 dígitos, C.P. de 5, correo válido', () {
      expect(ValidacionesOnboarding.telefono('4181234567'), isNull);
      expect(ValidacionesOnboarding.telefono('418123'), ErrorCampo.telefonoInvalido);
      expect(ValidacionesOnboarding.telefono('', opcional: true), isNull);
      expect(ValidacionesOnboarding.codigoPostal('37800'), isNull);
      expect(ValidacionesOnboarding.codigoPostal('3780'), ErrorCampo.codigoPostalInvalido);
      expect(ValidacionesOnboarding.correo('ana@e2e.mx'), isNull);
      expect(ValidacionesOnboarding.correo('ana@'), ErrorCampo.correoInvalido);
    });
  });

  group('Ingreso y credenciales', () {
    test('ingreso mayor a cero con máximo dos decimales', () {
      expect(ValidacionesOnboarding.ingreso('25000.50'), isNull);
      expect(ValidacionesOnboarding.ingreso('0'), ErrorCampo.ingresoInvalido);
      expect(ValidacionesOnboarding.ingreso('10.555'), ErrorCampo.ingresoInvalido);
    });

    test('política de contraseñas', () {
      expect(ValidacionesOnboarding.contrasenia('Segura123!'), isNull);
      expect(
        ValidacionesOnboarding.reglasIncumplidas('segura'),
        containsAll([
          ReglaContrasenia.longitud,
          ReglaContrasenia.mayuscula,
          ReglaContrasenia.numero,
          ReglaContrasenia.especial,
        ]),
      );
      expect(ValidacionesOnboarding.confirmacion('Otra123!', 'Segura123!'), ErrorCampo.contraseniasDistintas);
    });

    test('PIN de exactamente 4 dígitos', () {
      expect(ValidacionesOnboarding.pin('1234'), isNull);
      expect(ValidacionesOnboarding.pin('12345'), ErrorCampo.pinInvalido);
      expect(ValidacionesOnboarding.pin('12a4'), ErrorCampo.pinInvalido);
    });
  });

  test('la solicitud envía opcionales vacíos como null, normaliza y no expone secretos', () {
    final s = SolicitudRegistro()
      ..nombre = ' Ana '
      ..fechaNacimiento = nacimiento
      ..curp = 'magj950515hdfrrn01'
      ..correo = 'Ana@E2E.mx'
      ..contrasenia = 'Segura123!'
      ..pin = '1234';
    final json = s.toJson();

    expect((json['persona'] as Map)['nombre'], 'Ana');
    expect((json['persona'] as Map)['segundoNombre'], isNull);
    expect((json['persona'] as Map)['fechaNacimiento'], '1995-05-15');
    expect((json['persona'] as Map)['curp'], 'MAGJ950515HDFRRN01');
    expect((json['contacto'] as Map)['correo'], 'ana@e2e.mx');
    expect((json['laboral'] as Map)['monedaIngreso'], 'MXN');
    expect(json.containsKey('cuenta'), isTrue);
    expect(((json['cuenta'] as Map)).containsKey('saldoInicial'), isFalse);
    expect(s.toString(), isNot(contains('Segura123!')));
  });
}
