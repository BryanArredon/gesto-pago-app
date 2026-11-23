import 'transaccion.dart';

/// Parámetros para iniciar un pago de servicio.
class PagoRequest {
  const PagoRequest({
    required this.numeroCuenta,
    required this.pinAutorizacion,
    required this.idServicio,
    required this.idProducto,
    required this.referencia,
    required this.monto,
    required this.idempotencyKey,
  });

  /// Cuenta bancaria de 10 dígitos (onboarding-clientes) de la que se paga.
  final String numeroCuenta;

  /// PIN de 4 dígitos que autoriza la retención de saldo. Nunca se persiste.
  final String pinAutorizacion;

  final int idServicio;
  final int idProducto;
  final String referencia;
  final String monto;

  /// Identificador único de la intención de pago: estable entre reintentos
  /// para no duplicar cargos (idempotencia).
  final String idempotencyKey;

  Map<String, dynamic> toJson() => {
    'numeroCuenta': numeroCuenta,
    'pinAutorizacion': pinAutorizacion,
    'idServicio': idServicio,
    'idProducto': idProducto,
    'referencia': referencia,
    'monto': monto,
    'idempotencyKey': idempotencyKey,
  };

  @override
  String toString() =>
      'PagoRequest(cuenta: ****${numeroCuenta.length >= 4 ? numeroCuenta.substring(numeroCuenta.length - 4) : ''}, '
      'pin: ****, servicio: $idServicio, producto: $idProducto, monto: $monto)';
}

abstract interface class PagosRepository {
  Future<VerificacionReferencia> verificarReferencia({
    required int idServicio,
    required int idProducto,
    required String referencia,
  });

  Future<Transaccion> crearTransaccion(PagoRequest request);

  Future<Transaccion> confirmarTransaccion(int id);

  Future<List<Transaccion>> historial();
}
