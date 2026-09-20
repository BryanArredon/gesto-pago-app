import 'package:dio/dio.dart';

import '../../../core/network/app_exception.dart';
import '../domain/catalogo_producto.dart';

class CatalogoRemote {
  CatalogoRemote(this._dio);

  final Dio _dio;

  Future<List<CatalogoProducto>> obtenerProductos() async {
    final response = await _dio.get<List<dynamic>>('/catalogo/productos');
    final data = response.data;
    if (data == null) {
      throw const SerializationException('Catálogo vacío.');
    }
    return data.map((e) => CatalogoProducto.fromJson(e as Map<String, dynamic>)).toList();
  }
}