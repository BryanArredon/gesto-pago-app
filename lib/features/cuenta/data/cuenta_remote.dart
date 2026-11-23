import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/app_exception.dart';
import '../domain/cuenta.dart';

/// Consultas a onboarding-clientes. El servidor limita el alcance al cliente
/// del token (prevención de IDOR), así que solo se ven datos propios.
class CuentaRemote {
  CuentaRemote(this._dio);

  final Dio _dio;

  Future<List<Cuenta>> cuentasActivas(String clienteId) async {
    try {
      final response = await _dio.post(
        '/cuentas/consulta',
        data: {'clienteId': clienteId, 'soloActivas': true, 'limite': 20},
      );
      final data = response.data;
      final elementos = data is Map ? data['elementos'] : null;
      if (elementos is! List) {
        throw const SerializationException('Respuesta de cuentas inválida.');
      }
      return elementos.whereType<Map<String, dynamic>>().map(Cuenta.fromJson).toList();
    } catch (e) {
      throw ApiClient.unwrap(e);
    }
  }

  Future<ClienteDetalle> detalle(String clienteId) async {
    try {
      final response = await _dio.post('/clientes/detalle', data: {'id': clienteId});
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const SerializationException('Respuesta de cliente inválida.');
      }
      return ClienteDetalle.fromJson(data);
    } catch (e) {
      throw ApiClient.unwrap(e);
    }
  }

  Future<void> cambiarPin({
    required String usuarioId,
    required String contraseniaActual,
    required String nuevoPin,
  }) async {
    try {
      await _dio.put<void>(
        '/usuarios/pin',
        data: {'usuarioId': usuarioId, 'contraseniaActual': contraseniaActual, 'nuevoPin': nuevoPin},
      );
    } catch (e) {
      throw ApiClient.unwrap(e);
    }
  }
}
