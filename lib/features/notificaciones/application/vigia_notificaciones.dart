import '../../../core/network/app_exception.dart';
import '../../../core/notificaciones/notificador_sistema.dart';
import '../domain/notificacion_item.dart';
import '../domain/notificaciones_repository.dart';

/// Detecta notificaciones nuevas del servidor y las convierte en avisos del
/// celular (banner, sonido y vibración).
///
/// La primera revisión de cada sesión solo fija la línea base: lo que ya
/// estaba en la bandeja antes de entrar no se vuelve a anunciar.
class VigiaNotificaciones {
  VigiaNotificaciones({
    required this._repositorio,
    required this._notificador,
    required this._alCambiarContador,
    required this._resumen,
  });

  /// Más avisos que esto juntos se agrupan en uno solo, para no saturar la barra.
  static const maxAvisosIndividuales = 3;

  /// Id fijo del aviso de resumen: uno nuevo reemplaza al anterior.
  static const idAvisoResumen = 0;

  final NotificacionesRepository _repositorio;
  final NotificadorSistema _notificador;
  final void Function(int noLeidas) _alCambiarContador;
  final String Function(int nuevas) _resumen;

  int? _ultimoIdVisto;
  bool _revisando = false;

  /// Consulta la bandeja (sin contar como actividad de la sesión) y avisa de lo nuevo.
  Future<void> revisar() async {
    if (_revisando) {
      return;
    }
    _revisando = true;
    try {
      final pagina = await _repositorio.listar(tamanio: 20, soloNoLeidas: true, pasiva: true);
      _alCambiarContador(pagina.noLeidas);

      final base = _ultimoIdVisto;
      final maximo = pagina.items.fold<int>(base ?? 0, (m, n) => n.id > m ? n.id : m);
      _ultimoIdVisto = maximo;
      if (base == null) {
        return;
      }

      final nuevas = pagina.items.where((n) => n.id > base).toList()..sort((a, b) => a.id.compareTo(b.id));
      if (nuevas.isEmpty) {
        return;
      }
      if (nuevas.length > maxAvisosIndividuales) {
        await _notificador.mostrar(
          id: idAvisoResumen,
          titulo: 'Gesto Pago',
          cuerpo: _resumen(nuevas.length),
          ruta: '/notificaciones',
        );
        return;
      }
      for (final n in nuevas) {
        await _notificador.mostrar(id: n.id, titulo: n.titulo, cuerpo: n.cuerpo, ruta: rutaDe(n));
      }
    } on AppException {
      // Sin red o sesión perdida: el interceptor ya cerró la sesión si correspondía.
    } finally {
      _revisando = false;
    }
  }

  /// Al cerrar sesión: la siguiente sesión fija su propia línea base.
  void reiniciar() {
    _ultimoIdVisto = null;
  }

  /// A dónde lleva tocar el aviso: al comprobante si es de una compra.
  static String rutaDe(NotificacionItem n) =>
      n.transaccionId != null ? '/comprobante/${n.transaccionId}' : '/notificaciones';
}
