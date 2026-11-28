import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/app_exception.dart';
import '../../cuenta/domain/cuenta.dart';
import '../domain/solicitud_registro.dart';

/// Alta pública de cliente en onboarding-clientes: crea cliente, domicilio,
/// cuenta ACTIVA y usuario de acceso en una sola transacción.
class RegistroRemote {
  RegistroRemote(this._dio);

  final Dio _dio;

  Future<RegistroCompletado> registrar(SolicitudRegistro solicitud) async {
    try {
      final response = await _dio.post('/clientes', data: solicitud.toJson());
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const SerializationException('Respuesta de registro inválida.');
      }
      final cuenta = data['cuenta'] is Map ? data['cuenta'] as Map : const {};
      return RegistroCompletado(
        nombre: data['nombre']?.toString() ?? '',
        nombreCompleto: data['nombreCompleto']?.toString() ?? '',
        correo: valorDe(data['correo']),
        numeroCuenta: valorDe(cuenta['numero']),
        tipoCuenta: cuenta['tipo']?.toString() ?? '',
        estatusCuenta: cuenta['estatus']?.toString() ?? '',
        saldo: cuenta['saldo']?.toString() ?? '0',
      );
    } catch (e) {
      throw ApiClient.unwrap(e);
    }
  }
}
