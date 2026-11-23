import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gesto_pago_app/core/network/api_client.dart';
import 'package:gesto_pago_app/core/network/app_exception.dart';
import 'package:gesto_pago_app/core/network/token_refresher.dart';
import 'package:gesto_pago_app/core/network/token_store.dart';

import '../../support/fakes.dart';

/// Adaptador HTTP que responde según la ruta y registra el token enviado.
class _Servidor implements HttpClientAdapter {
  _Servidor(this.respuestas);

  final Map<String, (int, Map<String, dynamic>)> respuestas;
  final List<(String, String?)> peticiones = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    peticiones.add((options.path, options.headers['Authorization'] as String?));
    final (status, cuerpo) = respuestas[options.path] ?? (200, <String, dynamic>{});
    return ResponseBody.fromString(
      jsonEncode(cuerpo),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _Renovador implements TokenRefresher {
  int llamadas = 0;

  @override
  Future<String?> renovarSesion() async {
    llamadas++;
    return 'token-renovado';
  }
}

void main() {
  late FakeSecureStorage storage;
  late TokenStore store;
  late _Renovador renovador;
  MotivoCierre? motivo;

  Future<void> guardarSesion({required Duration expiraEn}) => store.save(
    SesionGuardada(
      accessToken: 'token-actual',
      expiraEn: DateTime.now().add(expiraEn),
      email: 'ana@e2e.mx',
      nombre: 'Ana',
      clienteId: 'c-1',
      usuarioId: 'u-1',
      sesionId: 's-1',
      rol: 'CLIENTE',
    ),
  );

  (ApiClient, _Servidor) cliente(Map<String, (int, Map<String, dynamic>)> respuestas) {
    final api = ApiClient(
      baseUrl: 'http://servidor',
      tokenStore: store,
      tokenRefresher: () => renovador,
      onSessionExpired: (m) => motivo = m,
    );
    final servidor = _Servidor(respuestas);
    api.dio.httpClientAdapter = servidor;
    return (api, servidor);
  }

  setUp(() {
    storage = FakeSecureStorage();
    store = TokenStore(storage);
    renovador = _Renovador();
    motivo = null;
  });

  test('PIN incorrecto (401 PAGO-008) NO cierra la sesión', () async {
    await guardarSesion(expiraEn: const Duration(minutes: 10));
    final (api, _) = cliente({
      '/pagos/transacciones': (401, {'code': 'PAGO-008', 'message': 'El PIN de autorizacion es incorrecto'}),
    });

    final error = await api.dio.post('/pagos/transacciones').then<Object?>((_) => null, onError: ApiClient.unwrap);

    expect(error, isA<UnauthorizedException>().having((e) => e.code, 'code', 'PAGO-008'));
    expect(motivo, isNull);
    expect(await store.readAccessToken(), 'token-actual');
  });

  test('sesión revocada desde otro canal (401 sesion_revocada) cierra con motivo revocada', () async {
    await guardarSesion(expiraEn: const Duration(minutes: 10));
    final (api, _) = cliente({
      '/clientes/detalle': (401, {'codigo': 'sesion_revocada', 'detail': 'Tu sesion se cerro'}),
    });

    await api.dio.post('/clientes/detalle').then<Object?>((_) => null, onError: ApiClient.unwrap);

    expect(motivo, MotivoCierre.revocada);
    expect(await store.readAccessToken(), isNull);
  });

  test('401 de api-gesto-pago sin código de negocio se trata como sesión perdida', () async {
    await guardarSesion(expiraEn: const Duration(minutes: 10));
    final (api, _) = cliente({
      '/catalogo/productos': (401, {'code': 'AUTH-005'}),
    });

    await api.dio.get('/catalogo/productos').then<Object?>((_) => null, onError: ApiClient.unwrap);

    expect(motivo, MotivoCierre.expirada);
  });

  test('los endpoints del login no llevan token ni cierran sesión con 401', () async {
    await guardarSesion(expiraEn: const Duration(minutes: 10));
    final (api, servidor) = cliente({
      '/auth/mfa/verificar': (401, {'codigo': 'codigo_mfa_invalido'}),
    });

    await api.dio.post('/auth/mfa/verificar').then<Object?>((_) => null, onError: ApiClient.unwrap);

    expect(servidor.peticiones.single.$2, isNull);
    expect(motivo, isNull);
  });

  test('renueva el token antes de que expire y usa el nuevo', () async {
    await guardarSesion(expiraEn: const Duration(seconds: 30));
    final (api, servidor) = cliente({});

    await api.dio.post('/cuentas/consulta');

    expect(renovador.llamadas, 1);
    expect(servidor.peticiones.single.$2, 'Bearer token-renovado');
  });

  test('con el token lejos de expirar no renueva', () async {
    await guardarSesion(expiraEn: const Duration(minutes: 10));
    final (api, servidor) = cliente({});

    await api.dio.post('/cuentas/consulta');

    expect(renovador.llamadas, 0);
    expect(servidor.peticiones.single.$2, 'Bearer token-actual');
  });

  test('409 sesion_activa conserva los detalles de la otra sesión', () async {
    final (api, _) = cliente({
      '/auth/mfa/verificar': (
        409,
        {
          'codigo': 'sesion_activa',
          'detail': 'Ya tienes una sesion activa en la web',
          'detalles': {'canal': 'WEB', 'dispositivo': 'Chrome', 'ultimaActividad': '2026-11-22T20:00:00Z'},
        },
      ),
    });

    final error = await api.dio.post('/auth/mfa/verificar').then<Object?>((_) => null, onError: ApiClient.unwrap);

    expect(error, isA<ConflictException>());
    final conflicto = error! as ConflictException;
    expect(conflicto.code, 'sesion_activa');
    expect(conflicto.detalles['canal'], 'WEB');
  });
}
