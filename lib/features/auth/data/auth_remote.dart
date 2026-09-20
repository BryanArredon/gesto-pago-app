import 'package:dio/dio.dart';

import '../../../core/network/app_exception.dart';
import '../../auth/domain/auth_session.dart';

class LoginResponse {
  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.nombre,
    required this.roles,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final accessToken = json['accessToken'];
    final refreshToken = json['refreshToken'];
    final nombre = json['nombre'] ?? '';
    if (accessToken is! String || refreshToken is! String) {
      throw const SerializationException('Respuesta de login inválida.');
    }
    return LoginResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 0,
      nombre: nombre,
      roles: (json['roles'] as List?)?.cast<String>() ?? const [],
    );
  }

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final String nombre;
  final List<String> roles;

  AuthSession toSession(String email) => AuthSession(
        email: email,
        nombre: nombre,
        accessToken: accessToken,
        refreshToken: refreshToken,
        roles: roles,
      );
}

/// Llamadas HTTP de autenticación contra el backend de la aplicación.
class AuthRemote {
  AuthRemote(this._dio);

  final Dio _dio;

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email.trim().toLowerCase(), 'password': password},
    );
    final data = response.data;
    if (data == null) {
      throw const SerializationException('Respuesta de login vacía.');
    }
    return LoginResponse.fromJson(data);
  }

  Future<LoginResponse> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {'nombre': nombre, 'email': email.trim().toLowerCase(), 'password': password},
    );
    final data = response.data;
    if (data == null) {
      throw const SerializationException('Respuesta de registro vacía.');
    }
    return LoginResponse.fromJson(data);
  }

  Future<LoginResponse> refresh({required String refreshToken}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    final data = response.data;
    if (data == null) {
      throw const SerializationException('Respuesta de refresh vacía.');
    }
    return LoginResponse.fromJson(data);
  }

  Future<void> logout({required String refreshToken}) async {
    await _dio.post<void>(
      '/auth/logout',
      options: Options(headers: {'Authorization': 'Refresh $refreshToken'}),
    );
  }
}