import 'transaccion.dart';

/// Datos con los que se abre el pago para repetir una compra anterior: el
/// usuario solo confirma y autoriza con su PIN.
class RepeticionPago {
  const RepeticionPago({required this.referencia});

  final String referencia;
}

/// Compras exitosas que vale la pena ofrecer para repetir: la más reciente de
/// cada combinación producto + referencia (la misma recarga al mismo número
/// aparece una sola vez), de la más nueva a la más vieja.
List<Transaccion> comprasParaRepetir(List<Transaccion> historial, {int maximo = 6}) {
  final aprobadas = historial.where((t) => t.esAprobada && t.referencia.trim().isNotEmpty).toList()
    ..sort((a, b) => b.fecha.compareTo(a.fecha));
  final vistas = <String>{};
  final resultado = <Transaccion>[];
  for (final t in aprobadas) {
    if (vistas.add('${t.idServicio}|${t.idProducto}|${t.referencia.trim()}')) {
      resultado.add(t);
      if (resultado.length == maximo) {
        break;
      }
    }
  }
  return resultado;
}

/// Referencia abreviada para mostrar en tarjetas pequeñas: los últimos 4
/// caracteres, como hacen las apps bancarias con números de cuenta y teléfono.
String referenciaCorta(String referencia) {
  final r = referencia.trim();
  return r.length > 4 ? '•••• ${r.substring(r.length - 4)}' : r;
}
