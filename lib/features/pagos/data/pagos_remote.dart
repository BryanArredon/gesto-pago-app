import 'package:dio/dio.dart';

import '../../../core/network/app_exception.dart';
import '../domain/transaccion.dart';

class PagosRemote {
  PagosRemote(this._dio);

  final Dio _dio;

  Future<VerificacionReferencia> verificarReferencia({
    required int idServicio,
    required int idProducto,
    required String referencia,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/pagos/verificar-referencia',
      data: {
        'idServicio': idServicio,
        'idProducto': idProducto,
        'referencia': referencia,
      },
    );
    final data = response.data;
    if (data == null) {
      throw const SerializationException('Verificación sin datos.');
    }
    return VerificacionReferencia.fromJson(data);
  }

  Future<Transaccion> crearTransaccion(Map<String, dynamic> request) async {
    final response = await _dio.post<Map<String, dynamic>>('/pagos/transacciones', data: request);
    return _parseTransaccion(response.data);
  }

  Future<Transaccion> confirmarTransaccion(int id) async {
    final response =
        await _dio.post<Map<String, dynamic>>('/pagos/transacciones/$id/confirmar');
    return _parseTransaccion(response.data);
  }

  Future<List<Transaccion>> historial() async {
    final response = await _dio.get<List<dynamic>>('/pagos/transacciones');
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data.map((e) => Transaccion.fromJson(e as Map<String, dynamic>)).toList();
  }

  Transaccion _parseTransaccion(Map<String, dynamic>? data) {
    if (data == null) {
      throw const SerializationException('Transacción sin datos.');
    }
    return Transaccion.fromJson(data);
  }
}