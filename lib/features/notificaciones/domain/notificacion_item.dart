/// Modelo de notificación para la bandeja de la app móvil.
class NotificacionItem {
  const NotificacionItem({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.cuerpo,
    this.transaccionId,
    this.datos = const {},
    this.leida = false,
    this.leidaEn,
    this.createdAt,
  });

  factory NotificacionItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseFecha(dynamic val) {
      if (val == null) return null;
      if (val is String) {
        return DateTime.tryParse(val);
      }
      return null;
    }

    final rawDatos = json['datos'];
    final Map<String, dynamic> mapDatos;
    if (rawDatos is Map) {
      mapDatos = Map<String, dynamic>.from(rawDatos);
    } else {
      mapDatos = const {};
    }

    return NotificacionItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      tipo: json['tipo'] as String? ?? 'TRANSACCION',
      titulo: json['titulo'] as String? ?? '',
      cuerpo: json['cuerpo'] as String? ?? '',
      transaccionId: (json['transaccionId'] as num?)?.toInt(),
      datos: mapDatos,
      leida: json['leida'] == true,
      leidaEn: parseFecha(json['leidaEn']),
      createdAt: parseFecha(json['createdAt']),
    );
  }

  final int id;
  final String tipo;
  final String titulo;
  final String cuerpo;
  final int? transaccionId;
  final Map<String, dynamic> datos;
  final bool leida;
  final DateTime? leidaEn;
  final DateTime? createdAt;

  NotificacionItem copyWith({
    bool? leida,
    DateTime? leidaEn,
  }) {
    return NotificacionItem(
      id: id,
      tipo: tipo,
      titulo: titulo,
      cuerpo: cuerpo,
      transaccionId: transaccionId,
      datos: datos,
      leida: leida ?? this.leida,
      leidaEn: leidaEn ?? this.leidaEn,
      createdAt: createdAt,
    );
  }

  /// Estado de la transacción asociada si existe (ej: LIQUIDADO, REVERSADO, PENDIENTE, REQUIERE_REVISION).
  String? get estado {
    final raw = datos['estado'] ?? datos['status'];
    return raw?.toString().trim().toUpperCase();
  }

  /// Código de error retornado por GestoPago si fue una transacción fallida o rechazada.
  String? get codigoErrorGestoPago {
    final val = datos['codigoErrorGestoPago'] ??
        datos['codigoError'] ??
        datos['codigoGestoPago'] ??
        datos['codigoRespuesta'] ??
        datos['codigo'];
    if (val != null && val.toString().trim().isNotEmpty) {
      return val.toString().trim();
    }
    return null;
  }

  /// Motivo claro del rechazo.
  String? get motivoRechazo {
    final val = datos['motivoRechazo'] ??
        datos['motivo'] ??
        datos['razonRechazo'] ??
        datos['razon'] ??
        datos['mensajeRechazo'];
    if (val != null && val.toString().trim().isNotEmpty) {
      return val.toString().trim();
    }
    return null;
  }

  /// Detalle técnico o extendido del error.
  String? get detalleError {
    final val = datos['detalleError'] ??
        datos['detalle'] ??
        datos['errorMensaje'] ??
        datos['descripcionError'];
    if (val != null && val.toString().trim().isNotEmpty) {
      return val.toString().trim();
    }
    return null;
  }

  /// Monto reportado en los datos del evento.
  String? get monto => datos['monto']?.toString();

  /// Comisión reportada en los datos del evento.
  String? get comision => datos['comision']?.toString();

  /// Nombre del servicio (ej. CFE, Telmex).
  String? get servicio => datos['servicio']?.toString();

  /// Nombre del producto (ej. Luz, Recarga).
  String? get producto => datos['producto']?.toString();

  /// Referencia de pago.
  String? get referencia => datos['referencia']?.toString();

  /// Indica si la notificación corresponde a una transacción rechazada, reversada o con error.
  bool get esRechazadaOFallida {
    final est = estado ?? '';
    if (est == 'REVERSADO' ||
        est == 'REVERSANDO' ||
        est == 'FALLIDA' ||
        est == 'RECHAZADO' ||
        est == 'RECHAZADA' ||
        est == 'REQUIERE_REVISION') {
      return true;
    }
    if (codigoErrorGestoPago != null && codigoErrorGestoPago != '00') {
      return true;
    }
    if (motivoRechazo != null && motivoRechazo!.isNotEmpty) {
      return true;
    }
    final t = titulo.toLowerCase();
    if (t.contains('rechaz') || t.contains('revers') || t.contains('fall') || t.contains('error')) {
      return true;
    }
    return false;
  }

  /// Motivo claro y amigable del rechazo para mostrar en la tarjeta.
  String get motivoExplicado {
    final mot = motivoRechazo;
    if (mot != null && mot.isNotEmpty) {
      return mot;
    }
    final det = detalleError;
    if (det != null && det.isNotEmpty) {
      return det;
    }
    final cod = codigoErrorGestoPago;
    if (cod != null && cod.isNotEmpty) {
      return 'Operación rechazada por el proveedor (código $cod).';
    }
    if (estado == 'REVERSADO') {
      return 'El proveedor rechazó la transacción y se completó la reversión.';
    }
    if (estado == 'REVERSANDO') {
      return 'El proveedor reportó un inconveniente con el pago; se inició la reversión.';
    }
    if (estado == 'REQUIERE_REVISION') {
      return 'El proveedor no pudo confirmar inmediatamente la operación. En proceso de aclaración.';
    }
    if (estado == 'FALLIDA' || estado == 'RECHAZADO' || estado == 'RECHAZADA') {
      return 'No fue posible procesar el pago con el proveedor o la referencia es inválida.';
    }
    return 'Transacción no completada.';
  }

  /// Aclaración clara del estado del saldo del usuario.
  String get aclaracionSaldo {
    final est = estado ?? '';
    switch (est) {
      case 'REVERSADO':
        return 'Tu saldo retenido fue liberado y devuelto a tu cuenta. No se realizó ningún cargo.';
      case 'REVERSANDO':
        return 'El reverso del cargo está en proceso. El monto retenido se acreditará en tu saldo automáticamente.';
      case 'REQUIERE_REVISION':
        return 'Tu saldo permanece retenido y protegido mientras nuestro equipo aclara el estatus con el proveedor.';
      case 'FALLIDA':
      case 'RECHAZADO':
      case 'RECHAZADA':
        return 'La operación no se ejecutó. Tu saldo disponible no fue afectado.';
      default:
        if (esRechazadaOFallida) {
          return 'Tu saldo se encuentra protegido y devuelto a tu cuenta sin cargos adicionales.';
        }
        return '';
    }
  }
}

/// Respuesta paginada de notificaciones.
class NotificacionesPagina {
  const NotificacionesPagina({
    required this.items,
    required this.total,
    required this.noLeidas,
    required this.pagina,
    required this.tamanio,
  });

  factory NotificacionesPagina.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return NotificacionesPagina(
      items: rawItems
          .map((e) => NotificacionItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      noLeidas: (json['noLeidas'] as num?)?.toInt() ?? 0,
      pagina: (json['pagina'] as num?)?.toInt() ?? 0,
      tamanio: (json['tamanio'] as num?)?.toInt() ?? 20,
    );
  }

  final List<NotificacionItem> items;
  final int total;
  final int noLeidas;
  final int pagina;
  final int tamanio;
}
