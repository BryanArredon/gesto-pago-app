import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/app_exception.dart';
import '../domain/notificacion_item.dart';

class NotificacionesRemote {
  NotificacionesRemote(this._dio);

  final Dio _dio;

  /// Obtiene la lista paginada de notificaciones.
  Future<NotificacionesPagina> listar({
    int pagina = 0,
    int tamanio = 20,
    bool soloNoLeidas = false,
    bool pasiva = false,
  }) async {
    try {
      final response = await _dio.get(
        '/notificaciones',
        queryParameters: {
          'pagina': pagina,
          'tamanio': tamanio,
          'soloNoLeidas': soloNoLeidas,
        },
        options: pasiva ? Options(headers: const {AppConfig.cabeceraConsultaPasiva: 'true'}) : null,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return NotificacionesPagina.fromJson(data);
      }
      if (data is Map) {
        return NotificacionesPagina.fromJson(Map<String, dynamic>.from(data));
      }
      throw const SerializationException('Respuesta de notificaciones inválida.');
    } catch (e) {
      throw ApiClient.unwrap(e);
    }
  }

  /// Consulta el número de notificaciones no leídas.
  Future<int> contarNoLeidas() async {
    try {
      final response = await _dio.get('/notificaciones/no-leidas/contador');
      final data = response.data;
      if (data is Map) {
        final count = data['noLeidas'] ?? data['count'] ?? data['contador'];
        if (count is num) {
          return count.toInt();
        }
      }
      return 0;
    } catch (e) {
      throw ApiClient.unwrap(e);
    }
  }

  /// Marca una notificación como leída.
  Future<bool> marcarLeida(int id) async {
    try {
      final response = await _dio.patch('/notificaciones/$id/leida');
      return response.statusCode == 200;
    } catch (e) {
      throw ApiClient.unwrap(e);
    }
  }

  /// Marca todas las notificaciones como leídas.
  /// Soporta el endpoint estándar /notificaciones/leidas y el alias /notificaciones/leer-todas.
  Future<int> marcarTodasLeidas() async {
    try {
      Response response;
      try {
        response = await _dio.patch('/notificaciones/leidas');
      } on DioException catch (dioErr) {
        if (dioErr.response?.statusCode == 404) {
          response = await _dio.patch('/notificaciones/leer-todas');
        } else {
          rethrow;
        }
      }

      final data = response.data;
      if (data is Map) {
        final total = data['actualizadas'] ?? data['total'] ?? data['count'];
        if (total is num) {
          return total.toInt();
        }
      }
      return 0;
    } catch (e) {
      throw ApiClient.unwrap(e);
    }
  }
}

