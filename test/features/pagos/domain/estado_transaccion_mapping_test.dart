import 'package:flutter_test/flutter_test.dart';

import 'package:gesto_pago_app/features/pagos/domain/estado_transaccion.dart';
import 'package:gesto_pago_app/features/pagos/domain/pagos_repository.dart';

void main() {
  group('EstadoTransaccion.fromApi (estados de la saga del backend)', () {
    test('solo LIQUIDADO es una compra realizada', () {
      expect(EstadoTransaccion.fromApi('LIQUIDADO'), EstadoTransaccion.aprobada);
    });

    test('REVERSADO es una compra rechazada', () {
      expect(EstadoTransaccion.fromApi('REVERSADO'), EstadoTransaccion.fallida);
    });

    test('estados intermedios quedan en proceso (confirmables)', () {
      for (final e in ['RETENIDO', 'EN_PROCESO', 'REVERSANDO', 'REQUIERE_REVISION']) {
        expect(EstadoTransaccion.fromApi(e), EstadoTransaccion.enProceso, reason: e);
      }
    });

    test('compatibilidad con estados del esquema anterior', () {
      expect(EstadoTransaccion.fromApi('APROBADA'), EstadoTransaccion.aprobada);
      expect(EstadoTransaccion.fromApi('PENDIENTE'), EstadoTransaccion.pendiente);
    });

    test('un estado desconocido nunca se muestra como fallo (podría haber fondos retenidos)', () {
      expect(EstadoTransaccion.fromApi('XXXX'), EstadoTransaccion.pendiente);
      expect(EstadoTransaccion.fromApi(''), EstadoTransaccion.pendiente);
    });
  });

  test('PagoRequest envía cuenta y PIN pero nunca los expone en toString', () {
    const request = PagoRequest(
      numeroCuenta: '0000000034',
      pinAutorizacion: '1234',
      idServicio: 1,
      idProducto: 2,
      referencia: '4181234567',
      monto: '50',
      idempotencyKey: 'abc123',
    );

    expect(request.toJson()['numeroCuenta'], '0000000034');
    expect(request.toJson()['pinAutorizacion'], '1234');
    expect(request.toString(), isNot(contains('1234')));
    expect(request.toString(), contains('****0034'));
  });
}
