import 'package:dio/dio.dart';

import '../../../core/network/app_exception.dart';
import '../domain/persona.dart';

class PersonaRemote {
  PersonaRemote(this._dio);

  final Dio _dio;

  Future<Persona> crearPersona(Persona persona) async {
    final response = await _dio.post<Map<String, dynamic>>('/personas', data: persona.toJson());
    return _parse(response.data);
  }

  Future<Persona> actualizarPersona(Persona persona) async {
    final response =
        await _dio.put<Map<String, dynamic>>('/personasActualiza', data: persona.toJson());
    return _parse(response.data);
  }

  Persona _parse(Map<String, dynamic>? data) {
    if (data == null) {
      throw const SerializationException('Respuesta de persona vacía.');
    }
    return Persona.fromJson(data);
  }
}