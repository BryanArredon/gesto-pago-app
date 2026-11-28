import 'package:flutter_test/flutter_test.dart';

import 'package:gesto_pago_app/core/network/app_exception.dart';
import 'package:gesto_pago_app/core/notificaciones/notificador_sistema.dart';
import 'package:gesto_pago_app/features/notificaciones/application/vigia_notificaciones.dart';
import 'package:gesto_pago_app/features/notificaciones/domain/notificacion_item.dart';
import 'package:gesto_pago_app/features/notificaciones/domain/notificaciones_repository.dart';

class _Bandeja implements NotificacionesRepository {
  List<NotificacionItem> items = [];
  bool fallar = false;
  final List<bool> consultasPasivas = [];

  @override
  Future<NotificacionesPagina> listar({
    int pagina = 0,
    int tamanio = 20,
    bool soloNoLeidas = false,
    bool pasiva = false,
  }) async {
    consultasPasivas.add(pasiva);
    if (fallar) {
      throw const NetworkException('sin red');
    }
    return NotificacionesPagina(items: items, total: items.length, noLeidas: items.length, pagina: 0, tamanio: 20);
  }

  @override
  Future<int> contarNoLeidas() async => items.length;

  @override
  Future<bool> marcarLeida(int id) async => true;

  @override
  Future<int> marcarTodasLeidas() async => items.length;
}

class _Avisos implements NotificadorSistema {
  final List<(int, String, String)> mostrados = [];

  @override
  Future<void> inicializar({required void Function(String ruta) alTocar}) async {}

  @override
  Future<bool> solicitarPermiso() async => true;

  @override
  Future<void> mostrar({required int id, required String titulo, required String cuerpo, required String ruta}) async {
    mostrados.add((id, titulo, ruta));
  }
}

NotificacionItem _n(int id, {int? tx}) =>
    NotificacionItem(id: id, tipo: 'TRANSACCION', titulo: 'Aviso $id', cuerpo: 'Cuerpo $id', transaccionId: tx);

void main() {
  late _Bandeja bandeja;
  late _Avisos avisos;
  late VigiaNotificaciones vigia;
  int? contador;

  setUp(() {
    bandeja = _Bandeja();
    avisos = _Avisos();
    contador = null;
    vigia = VigiaNotificaciones(
      repositorio: bandeja,
      notificador: avisos,
      alCambiarContador: (n) => contador = n,
      resumen: (n) => '$n nuevos',
    );
  });

  test('la primera revisión solo fija la línea base: no anuncia lo que ya estaba', () async {
    bandeja.items = [_n(1), _n(2)];

    await vigia.revisar();

    expect(avisos.mostrados, isEmpty);
    expect(contador, 2);
  });

  test('anuncia cada movimiento nuevo y abre su comprobante al tocarlo', () async {
    bandeja.items = [_n(1)];
    await vigia.revisar();

    bandeja.items = [_n(3, tx: 77), _n(2), _n(1)];
    await vigia.revisar();

    expect(avisos.mostrados, [(2, 'Aviso 2', '/notificaciones'), (3, 'Aviso 3', '/comprobante/77')]);

    await vigia.revisar();
    expect(avisos.mostrados, hasLength(2), reason: 'no repite avisos ya mostrados');
  });

  test('si llegan muchos juntos los agrupa en un solo aviso', () async {
    await vigia.revisar();
    bandeja.items = [for (var i = 1; i <= 5; i++) _n(i)];

    await vigia.revisar();

    expect(avisos.mostrados, [(VigiaNotificaciones.idAvisoResumen, 'Gesto Pago', '/notificaciones')]);
  });

  test('las consultas son pasivas para no mantener viva la sesión', () async {
    await vigia.revisar();
    await vigia.revisar();

    expect(bandeja.consultasPasivas, everyElement(isTrue));
  });

  test('tras reiniciar (otra sesión) vuelve a fijar la línea base', () async {
    await vigia.revisar();
    vigia.reiniciar();
    bandeja.items = [_n(9)];

    await vigia.revisar();

    expect(avisos.mostrados, isEmpty);
  });

  test('sin red no falla ni anuncia nada', () async {
    bandeja.fallar = true;

    await vigia.revisar();

    expect(avisos.mostrados, isEmpty);
  });
}
