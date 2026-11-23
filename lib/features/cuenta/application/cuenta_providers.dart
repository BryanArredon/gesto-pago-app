import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../auth/application/session_controller.dart';
import '../domain/cuenta.dart';

/// Cuenta activa con la que se paga (la primera ACTIVA del cliente).
final cuentaActivaProvider = FutureProvider.autoDispose<Cuenta?>((ref) async {
  final clienteId = ref.watch(sessionControllerProvider.select((s) => s.session?.clienteId));
  if (clienteId == null) {
    return null;
  }
  final cuentas = await ref.watch(cuentaRemoteProvider).cuentasActivas(clienteId);
  return cuentas.where((c) => c.activa).firstOrNull;
});

/// Datos del cliente autenticado. Alimenta el nombre que muestra la sesión.
final clienteDetalleProvider = FutureProvider.autoDispose<ClienteDetalle?>((ref) async {
  final clienteId = ref.watch(sessionControllerProvider.select((s) => s.session?.clienteId));
  if (clienteId == null) {
    return null;
  }
  final detalle = await ref.watch(cuentaRemoteProvider).detalle(clienteId);
  ref.read(sessionControllerProvider.notifier).actualizarNombre(detalle.nombre);
  return detalle;
});
