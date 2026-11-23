import 'package:flutter_test/flutter_test.dart';

import 'package:gesto_pago_app/features/auth/domain/desafio_mfa.dart';
import 'package:gesto_pago_app/features/cuenta/domain/cuenta.dart';

void main() {
  test('Cuenta acepta value objects serializados como {"valor": ...}', () {
    final cuenta = Cuenta.fromJson({
      'id': 'x',
      'numero': {'valor': '0000000034'},
      'tipo': 'AHORRO',
      'moneda': 'MXN',
      'saldo': 1500.5,
      'estatus': 'ACTIVA',
    });

    expect(cuenta.numero, '0000000034');
    expect(cuenta.saldo, '1500.5');
    expect(cuenta.activa, isTrue);
    expect(cuenta.enmascarada, '•••• 0034');
    expect(cuenta.agrupada, '0000 0000 34');
  });

  test('ClienteDetalle arma el domicilio y lee el estado del PIN', () {
    final d = ClienteDetalle.fromJson({
      'id': 'c-1',
      'nombre': 'Ana',
      'nombreCompleto': 'Ana Lopez Ruiz',
      'correo': {'valor': 'ana@e2e.mx'},
      'curp': {'valor': 'LORA970717MGTPZN03'},
      'rfc': 'LORA970717AB3',
      'telefonoMovil': {'valor': '4181234567'},
      'domicilio': {
        'calle': 'Av. Universidad',
        'numeroExterior': '1',
        'colonia': 'Centro',
        'municipio': 'Dolores',
        'estado': 'Guanajuato',
        'codigoPostal': {'valor': '37800'},
      },
      'activo': true,
      'usuario': {'tienePin': true, 'ultimoAcceso': '2026-11-22T20:00:00Z'},
    });

    expect(d.correo, 'ana@e2e.mx');
    expect(d.curp, 'LORA970717MGTPZN03');
    expect(d.rfc, 'LORA970717AB3');
    expect(d.domicilio, 'Av. Universidad 1, Centro, Dolores, Guanajuato, 37800');
    expect(d.tienePin, isTrue);
    expect(d.ultimoAcceso, isNotNull);
  });

  test('SesionActivaInfo describe el dispositivo de la otra sesión', () {
    final web = SesionActivaInfo.desdeDetalles({
      'canal': 'WEB',
      'dispositivo': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 Chrome/131.0 Safari/537.36',
    });
    expect(web.esWeb, isTrue);
    expect(web.descripcionDispositivo, 'Chrome en macOS');

    final movil = SesionActivaInfo.desdeDetalles({'canal': 'MOVIL', 'dispositivo': 'Dart/3.5 (dart:io)'});
    expect(movil.descripcionDispositivo, 'App Gesto Pago');
  });
}
