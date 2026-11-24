import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/app_exception.dart';
import '../../../core/providers/app_providers.dart';
import '../domain/notificacion_item.dart';
import '../domain/notificaciones_repository.dart';

class NotificacionesState {
  const NotificacionesState({
    this.cargando = false,
    this.notificaciones = const [],
    this.total = 0,
    this.noLeidas = 0,
    this.soloNoLeidas = false,
    this.error,
    this.marcandoTodas = false,
  });

  final bool cargando;
  final List<NotificacionItem> notificaciones;
  final int total;
  final int noLeidas;
  final bool soloNoLeidas;
  final AppException? error;
  final bool marcandoTodas;

  NotificacionesState copyWith({
    bool? cargando,
    List<NotificacionItem>? notificaciones,
    int? total,
    int? noLeidas,
    bool? soloNoLeidas,
    AppException? error,
    bool clearError = false,
    bool? marcandoTodas,
  }) {
    return NotificacionesState(
      cargando: cargando ?? this.cargando,
      notificaciones: notificaciones ?? this.notificaciones,
      total: total ?? this.total,
      noLeidas: noLeidas ?? this.noLeidas,
      soloNoLeidas: soloNoLeidas ?? this.soloNoLeidas,
      error: clearError ? null : (error ?? this.error),
      marcandoTodas: marcandoTodas ?? this.marcandoTodas,
    );
  }
}

class NotificacionesController extends StateNotifier<NotificacionesState> {
  NotificacionesController(this._repository) : super(const NotificacionesState());

  final NotificacionesRepository _repository;

  /// Carga la lista de notificaciones desde el backend.
  Future<void> cargar({bool? soloNoLeidas}) async {
    final filtro = soloNoLeidas ?? state.soloNoLeidas;
    state = state.copyWith(cargando: true, clearError: true, soloNoLeidas: filtro);
    try {
      final pagina = await _repository.listar(
        pagina: 0,
        tamanio: 50,
        soloNoLeidas: filtro,
      );
      state = state.copyWith(
        cargando: false,
        notificaciones: pagina.items,
        total: pagina.total,
        noLeidas: pagina.noLeidas,
      );
    } on AppException catch (e) {
      state = state.copyWith(cargando: false, error: e);
    } catch (e) {
      state = state.copyWith(
        cargando: false,
        error: const ApiException('No se pudieron obtener las notificaciones.'),
      );
    }
  }

  /// Cambia el filtro de solo no leídas vs todas.
  Future<void> cambiarFiltro(bool soloNoLeidas) async {
    if (state.soloNoLeidas == soloNoLeidas && !state.cargando) {
      return;
    }
    await cargar(soloNoLeidas: soloNoLeidas);
  }

  /// Refresca las notificaciones y el contador.
  Future<void> refrescar() async {
    try {
      final pagina = await _repository.listar(
        pagina: 0,
        tamanio: 50,
        soloNoLeidas: state.soloNoLeidas,
      );
      state = state.copyWith(
        clearError: true,
        notificaciones: pagina.items,
        total: pagina.total,
        noLeidas: pagina.noLeidas,
      );
    } on AppException catch (e) {
      state = state.copyWith(error: e);
    }
  }

  /// Actualiza únicamente el contador de notificaciones no leídas.
  Future<void> actualizarContador() async {
    try {
      final count = await _repository.contarNoLeidas();
      state = state.copyWith(noLeidas: count);
    } catch (_) {
      // Ignorar fallo de sondeo del badge
    }
  }

  /// Marca una notificación como leída (optimista).
  Future<void> marcarLeida(int id) async {
    final index = state.notificaciones.indexWhere((n) => n.id == id);
    if (index == -1) return;

    final item = state.notificaciones[index];
    if (item.leida) return;

    final nuevaLista = List<NotificacionItem>.from(state.notificaciones);
    nuevaLista[index] = item.copyWith(leida: true, leidaEn: DateTime.now());
    final nuevoNoLeidas = state.noLeidas > 0 ? state.noLeidas - 1 : 0;

    // Si el filtro es solo no leídas, removemos el elemento
    if (state.soloNoLeidas) {
      nuevaLista.removeAt(index);
    }

    state = state.copyWith(
      notificaciones: nuevaLista,
      noLeidas: nuevoNoLeidas,
    );

    try {
      await _repository.marcarLeida(id);
    } catch (e) {
      // Si falla, sincronizar de nuevo
      await refrescar();
    }
  }

  /// Marca todas las notificaciones como leídas (optimista).
  Future<void> marcarTodasLeidas() async {
    if (state.noLeidas == 0 && state.notificaciones.every((n) => n.leida)) {
      return;
    }

    final fecha = DateTime.now();
    final nuevaLista = state.soloNoLeidas
        ? <NotificacionItem>[]
        : state.notificaciones.map((n) => n.copyWith(leida: true, leidaEn: fecha)).toList();

    state = state.copyWith(
      marcandoTodas: true,
      notificaciones: nuevaLista,
      noLeidas: 0,
    );

    try {
      await _repository.marcarTodasLeidas();
    } catch (e) {
      await refrescar();
    } finally {
      state = state.copyWith(marcandoTodas: false);
    }
  }
}

final notificacionesControllerProvider =
    StateNotifierProvider<NotificacionesController, NotificacionesState>((ref) {
  return NotificacionesController(ref.watch(notificacionesRepositoryProvider));
});

final notificacionesNoLeidasProvider = Provider<int>((ref) {
  return ref.watch(notificacionesControllerProvider.select((s) => s.noLeidas));
});

