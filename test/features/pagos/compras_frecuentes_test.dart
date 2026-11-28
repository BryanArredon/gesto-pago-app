import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gesto_pago_app/features/pagos/domain/compras_frecuentes.dart';
import 'package:gesto_pago_app/features/pagos/domain/estado_transaccion.dart';
import 'package:gesto_pago_app/features/pagos/domain/transaccion.dart';
import 'package:gesto_pago_app/features/pagos/presentation/compartir_comprobante.dart';
import 'package:gesto_pago_app/l10n/app_localizations.dart';

Transaccion _tx(
  int id, {
  int servicio = 1,
  int producto = 10,
  String referencia = '4181234567',
  String fecha = '2026-11-01T10:00:00Z',
  EstadoTransaccion estado = EstadoTransaccion.aprobada,
  String nombre = 'Telcel \$100',
}) => Transaccion(
  id: id,
  upc: 'UPC$id',
  idServicio: servicio,
  idProducto: producto,
  servicio: 'Telcel',
  producto: nombre,
  referencia: referencia,
  monto: '100.00',
  comision: '0',
  estado: estado,
  numeroAutorizacion: 'AUT$id',
  idTx: '',
  pin: '',
  legend: null,
  errorMensaje: null,
  fecha: fecha,
);

void main() {
  group('comprasParaRepetir', () {
    test('ofrece la compra más reciente de cada producto + referencia, sin duplicados', () {
      final r = comprasParaRepetir([
        _tx(1, fecha: '2026-11-01T10:00:00Z'),
        _tx(2, fecha: '2026-11-20T10:00:00Z'),
        _tx(3, referencia: '4189999999', fecha: '2026-11-10T10:00:00Z'),
        _tx(4, producto: 11, fecha: '2026-11-05T10:00:00Z'),
      ]);

      expect(r.map((t) => t.id), [2, 3, 4]);
    });

    test('solo ofrece compras exitosas', () {
      final r = comprasParaRepetir([
        _tx(1, estado: EstadoTransaccion.fallida),
        _tx(2, estado: EstadoTransaccion.pendiente, referencia: '1'),
        _tx(3, estado: EstadoTransaccion.enProceso, referencia: '2'),
      ]);

      expect(r, isEmpty);
    });

    test('respeta el máximo', () {
      final r = comprasParaRepetir([for (var i = 0; i < 10; i++) _tx(i, referencia: 'ref$i')], maximo: 4);

      expect(r, hasLength(4));
    });
  });

  test('referenciaCorta muestra solo los últimos 4 caracteres', () {
    expect(referenciaCorta('4181234567'), '•••• 4567');
    expect(referenciaCorta('123'), '123');
  });

  testWidgets('el PDF del comprobante se genera aunque el producto traiga símbolos fuera de Latin-1', (tester) async {
    late AppLocalizations l;
    await tester.pumpWidget(
      Localizations(
        locale: const Locale('es'),
        delegates: AppLocalizations.localizationsDelegates,
        child: Builder(
          builder: (context) {
            l = AppLocalizations.of(context);
            return const SizedBox();
          },
        ),
      ),
    );

    final bytes = await tester.runAsync(() => CompartirComprobante.pdf(_tx(1, nombre: 'Netflix™ “Premium” 🎬 – 1 mes'), l));

    expect(bytes, isNotNull);
    expect(String.fromCharCodes(bytes!.take(5)), '%PDF-');
    expect(CompartirComprobante.nombreArchivo(_tx(7), 'pdf'), 'comprobante-gestopago-UPC7.pdf');
  });
}
