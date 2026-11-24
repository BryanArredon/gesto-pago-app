import 'notificacion_item.dart';

abstract class NotificacionesRepository {
  Future<NotificacionesPagina> listar({
    int pagina = 0,
    int tamanio = 20,
    bool soloNoLeidas = false,
  });

  Future<int> contarNoLeidas();

  Future<bool> marcarLeida(int id);

  Future<int> marcarTodasLeidas();
}

