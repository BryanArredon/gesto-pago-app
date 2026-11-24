import '../domain/notificacion_item.dart';
import '../domain/notificaciones_repository.dart';
import 'notificaciones_remote.dart';

class NotificacionesRepositoryImpl implements NotificacionesRepository {
  NotificacionesRepositoryImpl(this._remote);

  final NotificacionesRemote _remote;

  @override
  Future<NotificacionesPagina> listar({
    int pagina = 0,
    int tamanio = 20,
    bool soloNoLeidas = false,
  }) {
    return _remote.listar(
      pagina: pagina,
      tamanio: tamanio,
      soloNoLeidas: soloNoLeidas,
    );
  }

  @override
  Future<int> contarNoLeidas() {
    return _remote.contarNoLeidas();
  }

  @override
  Future<bool> marcarLeida(int id) {
    return _remote.marcarLeida(id);
  }

  @override
  Future<int> marcarTodasLeidas() {
    return _remote.marcarTodasLeidas();
  }
}
