// Prueba de integración contra un onboarding-clientes real (nunca contra producción):
//
//   ONBOARDING_E2E_URL=http://127.0.0.1:8082 flutter test test/integration
//
// Usa las clases reales de la app (ApiClient, AuthRepositoryImpl, remotos) con un
// almacenamiento en memoria. Sin la variable de entorno se omite.
@Tags(['integracion'])
library;

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gesto_pago_app/core/network/api_client.dart';
import 'package:gesto_pago_app/core/network/app_exception.dart';
import 'package:gesto_pago_app/core/network/token_refresher.dart';
import 'package:gesto_pago_app/core/network/token_store.dart';
import 'package:gesto_pago_app/features/auth/data/auth_remote.dart';
import 'package:gesto_pago_app/features/auth/data/auth_repository_impl.dart';
import 'package:gesto_pago_app/features/cuenta/data/cuenta_remote.dart';
import 'package:gesto_pago_app/features/registro/data/registro_remote.dart';
import 'package:gesto_pago_app/features/registro/domain/solicitud_registro.dart';

import '../support/fakes.dart';

final _url = Platform.environment['ONBOARDING_E2E_URL'];

String _totp(String secreto, int paso) {
  const alfabeto = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  final bits = secreto.split('').map((c) => alfabeto.indexOf(c).toRadixString(2).padLeft(5, '0')).join();
  final clave = [for (var i = 0; i + 8 <= bits.length; i += 8) int.parse(bits.substring(i, i + 8), radix: 2)];
  final mensaje = ByteData(8)..setInt64(0, paso);
  final h = Hmac(sha1, clave).convert(mensaje.buffer.asUint8List()).bytes;
  final o = h.last & 0x0f;
  final valor = ((h[o] & 0x7f) << 24) | (h[o + 1] << 16) | (h[o + 2] << 8) | h[o + 3];
  return (valor % 1000000).toString().padLeft(6, '0');
}

int _pasoActual() => DateTime.now().millisecondsSinceEpoch ~/ 30000;

/// El servidor no acepta dos veces el mismo paso de 30 s (anti-replay).
Future<int> _esperarPasoNuevo(int usado) async {
  while (_pasoActual() <= usado) {
    await Future<void>.delayed(const Duration(seconds: 1));
  }
  return _pasoActual();
}

void main() {
  test(
    'alta, 2FA, una sola sesión entre canales, revocación y logout contra el backend real',
    () async {
      final motivos = <MotivoCierre>[];
      final store = TokenStore(FakeSecureStorage());
      late AuthRepositoryImpl repo;
      final cliente = ApiClient(
        baseUrl: _url!,
        tokenStore: store,
        tokenRefresher: () => repo,
        onSessionExpired: motivos.add,
      );
      repo = AuthRepositoryImpl(AuthRemote(cliente.dio), store);
      final cuentas = CuentaRemote(cliente.dio);

      // 1. Alta con CURP/RFC únicos por ejecución (fecha embebida = fecha de nacimiento).
      // Se varían las consonantes internas (posiciones 14-16) y el dígito verificador; la
      // posición 17 queda en '0' porque el CHECK de la BD solo admite [0-9HM] ahí.
      final azar = Random();
      final letras = String.fromCharCodes(List.generate(3, (_) => 66 + azar.nextInt(24)));
      final correo = 'flutter.${DateTime.now().millisecondsSinceEpoch}@e2e.mx';
      final solicitud = SolicitudRegistro()
        ..nombre = 'Ana'
        ..apellidoPaterno = 'Lopez'
        ..apellidoMaterno = 'Ruiz'
        ..fechaNacimiento = DateTime(1994, 4, 14)
        ..sexo = 'MUJER'
        ..curp = 'LORA940414MGT${letras}0${azar.nextInt(10)}'
        ..rfc = 'LORA940414${letras.substring(0, 2)}${azar.nextInt(10)}'
        ..estadoCivil = 'SOLTERO'
        ..correo = correo
        ..telefonoMovil = '4181234567'
        ..calle = 'Av. Universidad'
        ..numeroExterior = '1'
        ..colonia = 'Centro'
        ..municipio = 'Dolores'
        ..estado = 'Guanajuato'
        ..codigoPostal = '37800'
        ..ocupacion = 'Analista'
        ..ingresoMensual = '25000'
        ..contrasenia = 'Segura123!'
        ..pin = '1234';
      final alta = await RegistroRemote(cliente.dio).registrar(solicitud);
      expect(alta.numeroCuenta, matches(RegExp(r'^\d{10}$')));
      expect(alta.estatusCuenta, 'ACTIVA');

      // 2. Primer factor: exige enrolar la app autenticadora.
      final desafio = await repo.iniciarSesion(email: correo, password: 'Segura123!');
      expect(desafio.requiereEnrolamiento, isTrue);
      final secreto = desafio.secreto!;

      // 3. Segundo factor desde el móvil.
      var paso = _pasoActual();
      final sesion = await repo.verificarSegundoFactor(desafio: desafio, codigo: _totp(secreto, paso), email: correo);
      expect(sesion.email, correo);

      final misCuentas = await cuentas.cuentasActivas(sesion.clienteId);
      expect(misCuentas.single.numero, alta.numeroCuenta);
      final detalle = await cuentas.detalle(sesion.clienteId);
      expect(detalle.curp, solicitud.curp);
      expect(detalle.tienePin, isTrue);

      // 4. La web intenta entrar: 409 sesion_activa con el canal MOVIL; confirma y cierra la del móvil.
      final web = Dio(
        BaseOptions(baseUrl: _url!, validateStatus: (_) => true, headers: {'User-Agent': 'Chrome/131.0 (Windows)'}),
      );
      final desafioWeb = await web.post(
        '/auth/login',
        data: {'correo': correo, 'contrasenia': 'Segura123!', 'canal': 'WEB'},
      );
      paso = await _esperarPasoNuevo(paso);
      final datosWeb = {'tokenDesafio': desafioWeb.data['tokenDesafio'], 'codigo': _totp(secreto, paso)};
      final conflicto = await web.post('/auth/mfa/verificar', data: datosWeb);
      expect(conflicto.statusCode, 409);
      expect(conflicto.data['detalles']['canal'], 'MOVIL');
      final accesoWeb = await web.post('/auth/mfa/verificar', data: {...datosWeb, 'cerrarSesionAnterior': true});
      expect(accesoWeb.statusCode, 200);

      // 5. El móvil se entera en su siguiente petición: sesión revocada y almacenamiento limpio.
      await expectLater(cuentas.cuentasActivas(sesion.clienteId), throwsA(isA<UnauthorizedException>()));
      expect(motivos, [MotivoCierre.revocada]);
      expect(await store.readAccessToken(), isNull);

      // 6. El móvil recupera la sesión (cerrando la web) y luego la cierra en el servidor.
      final desafio2 = await repo.iniciarSesion(email: correo, password: 'Segura123!');
      expect(desafio2.requiereEnrolamiento, isFalse);
      paso = await _esperarPasoNuevo(paso);
      final sesion2 = await repo.verificarSegundoFactor(
        desafio: desafio2,
        codigo: _totp(secreto, paso),
        email: correo,
        cerrarSesionAnterior: true,
      );
      final tokenWeb = accesoWeb.data['accessToken'] as String;
      final webTrasReemplazo = await web.post(
        '/auth/sesion',
        options: Options(headers: {'Authorization': 'Bearer $tokenWeb'}),
      );
      expect(webTrasReemplazo.statusCode, 401);
      expect(webTrasReemplazo.data['codigo'], 'sesion_revocada');

      expect(await repo.renovarSesion(), isNotNull);
      final tokenMovil = await store.readAccessToken();
      await repo.logout();
      final trasLogout = await web.post(
        '/auth/sesion',
        options: Options(headers: {'Authorization': 'Bearer $tokenMovil'}),
      );
      expect(trasLogout.statusCode, 401);
      expect(sesion2.sesionId, isNot(sesion.sesionId));
    },
    skip: _url == null ? 'Define ONBOARDING_E2E_URL para ejecutar' : false,
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
