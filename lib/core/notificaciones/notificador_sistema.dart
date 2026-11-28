/// Avisos del sistema operativo (barra de notificaciones, banner, sonido y
/// vibración), como los de una app de mensajería.
///
/// Es una interfaz para que la lógica que decide *cuándo* avisar no dependa
/// del plugin nativo: en pruebas y en web se usa [NotificadorInactivo].
abstract interface class NotificadorSistema {
  /// Registra el canal de avisos. [alTocar] recibe la ruta de la app que abre
  /// el aviso (p. ej. el comprobante del movimiento).
  Future<void> inicializar({required void Function(String ruta) alTocar});

  /// Pide permiso al usuario (Android 13+ e iOS). Devuelve si lo concedió.
  Future<bool> solicitarPermiso();

  Future<void> mostrar({required int id, required String titulo, required String cuerpo, required String ruta});
}

/// Implementación vacía: plataformas sin avisos nativos y pruebas.
class NotificadorInactivo implements NotificadorSistema {
  const NotificadorInactivo();

  @override
  Future<void> inicializar({required void Function(String ruta) alTocar}) async {}

  @override
  Future<bool> solicitarPermiso() async => false;

  @override
  Future<void> mostrar({required int id, required String titulo, required String cuerpo, required String ruta}) async {}
}
