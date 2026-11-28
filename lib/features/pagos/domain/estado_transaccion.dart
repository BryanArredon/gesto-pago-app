/// Estado de una transacción tal como lo ve el usuario.
///
/// El backend maneja los 7 estados de la saga de pagos; aquí se reducen a lo
/// que importa al usuario. Solo [aprobada] (LIQUIDADO) es una compra realizada.
enum EstadoTransaccion {
  pendiente,
  enProceso,
  aprobada,
  fallida;

  static EstadoTransaccion fromApi(String valor) {
    switch (valor.toUpperCase()) {
      case 'LIQUIDADO':
      // Estados del esquema anterior, por compatibilidad con transacciones viejas.
      case 'APROBADA':
      case 'APROBADO':
      case 'EXITOSA':
        return EstadoTransaccion.aprobada;
      case 'REVERSADO':
      case 'FALLIDA':
      case 'RECHAZADA':
        return EstadoTransaccion.fallida;
      case 'RETENIDO':
      case 'EN_PROCESO':
      case 'PROCESANDO':
      case 'REVERSANDO':
      case 'REQUIERE_REVISION':
        return EstadoTransaccion.enProceso;
      default:
        // Un estado desconocido nunca se presenta como fallo: los fondos podrían
        // estar retenidos. Se muestra como pendiente hasta confirmarlo.
        return EstadoTransaccion.pendiente;
    }
  }
}
