import 'package:flutter_test/flutter_test.dart';
import 'package:gesto_pago_app/features/notificaciones/domain/notificacion_item.dart';

void main() {
  group('NotificacionItem model tests', () {
    test('Parsea correctamente JSON de notificacion con error de GestoPago', () {
      final json = {
        'id': 101,
        'tipo': 'TRANSACCION',
        'titulo': 'Pago no aplicado',
        'cuerpo': 'Tu pago de CFE no se pudo aplicar.',
        'transaccionId': 456,
        'datos': {
          'estado': 'REVERSADO',
          'monto': '450.00',
          'comision': '5.00',
          'servicio': 'CFE',
          'producto': 'Luz',
          'referencia': '018001234567',
          'codigoErrorGestoPago': 'ERR-02',
          'motivoRechazo': 'Referencia inexistente o vencida',
          'detalleError': 'El proveedor rechazó la referencia por fecha vencida.',
        },
        'leida': false,
        'leidaEn': null,
        'createdAt': '2026-11-23T20:15:00Z',
      };

      final item = NotificacionItem.fromJson(json);

      expect(item.id, 101);
      expect(item.tipo, 'TRANSACCION');
      expect(item.titulo, 'Pago no aplicado');
      expect(item.transaccionId, 456);
      expect(item.leida, false);
      expect(item.estado, 'REVERSADO');
      expect(item.codigoErrorGestoPago, 'ERR-02');
      expect(item.motivoRechazo, 'Referencia inexistente o vencida');
      expect(item.esRechazadaOFallida, true);
      expect(item.motivoExplicado, 'Referencia inexistente o vencida');
      expect(item.aclaracionSaldo, contains('liberado y devuelto a tu cuenta'));
    });

    test('Parsea correctamente notificacion exitosa (LIQUIDADO)', () {
      final json = {
        'id': 102,
        'tipo': 'TRANSACCION',
        'titulo': 'Pago exitoso',
        'cuerpo': 'Tu pago de Telmex fue procesado.',
        'transaccionId': 457,
        'datos': {
          'estado': 'LIQUIDADO',
          'monto': '299.00',
          'servicio': 'Telmex',
        },
        'leida': true,
        'createdAt': '2026-11-23T19:00:00Z',
      };

      final item = NotificacionItem.fromJson(json);

      expect(item.id, 102);
      expect(item.leida, true);
      expect(item.estado, 'LIQUIDADO');
      expect(item.esRechazadaOFallida, false);
      expect(item.codigoErrorGestoPago, isNull);
    });

    test('NotificacionesPagina parsea lista de items', () {
      final json = {
        'items': [
          {'id': 1, 'titulo': 'Notif 1', 'leida': false},
          {'id': 2, 'titulo': 'Notif 2', 'leida': true},
        ],
        'total': 2,
        'noLeidas': 1,
        'pagina': 0,
        'tamanio': 20,
      };

      final pagina = NotificacionesPagina.fromJson(json);
      expect(pagina.total, 2);
      expect(pagina.noLeidas, 1);
      expect(pagina.items.length, 2);
      expect(pagina.items[0].id, 1);
      expect(pagina.items[1].id, 2);
    });

    test('Aclaraciones de saldo por estado', () {
      final reversado = NotificacionItem(
        id: 1,
        tipo: 'TRANSACCION',
        titulo: 'Pago cancelado',
        cuerpo: '...',
        datos: const {'estado': 'REVERSADO'},
      );
      expect(reversado.aclaracionSaldo, contains('No se realizó ningún cargo'));

      final reversando = NotificacionItem(
        id: 2,
        tipo: 'TRANSACCION',
        titulo: 'Reversión',
        cuerpo: '...',
        datos: const {'estado': 'REVERSANDO'},
      );
      expect(reversando.aclaracionSaldo, contains('El reverso del cargo está en proceso'));

      final revision = NotificacionItem(
        id: 3,
        tipo: 'TRANSACCION',
        titulo: 'Revisión',
        cuerpo: '...',
        datos: const {'estado': 'REQUIERE_REVISION'},
      );
      expect(revision.aclaracionSaldo, contains('permanece retenido y protegido'));
    });
  });
}
