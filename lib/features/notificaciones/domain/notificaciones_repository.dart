import 'notificacion_item.dart';

abstract class NotificacionesRepository {
  Future<NotificacionesPagina> listar({
    int pagina = 0,
    int tamanio = 20,
    bool soloNoLeidas = false,
    // Sondeo automático: no cuenta como actividad del usuario (no alarga la sesión).
    bool pasiva = false,
  });

  Future<int> contarNoLeidas();

  Future<bool> marcarLeida(int id);

  Future<int> marcarTodasLeidas();
}

