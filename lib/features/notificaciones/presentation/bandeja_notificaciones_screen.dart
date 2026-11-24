import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/gp_colors.dart';
import '../../../core/theme/gp_theme.dart';
import '../../../core/widgets/app_empty_view.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/brand_mark.dart';
import '../application/notificaciones_controller.dart';
import '../domain/notificacion_item.dart';

/// Pantalla de bandeja de notificaciones de la app móvil.
/// Muestra notificaciones en tiempo real, permite filtrar por leídas/no leídas,
/// marcar como leídas y presenta alertas destacadas para transacciones fallidas/rechazadas.
class BandejaNotificacionesScreen extends ConsumerStatefulWidget {
  const BandejaNotificacionesScreen({super.key});

  @override
  ConsumerState<BandejaNotificacionesScreen> createState() => _BandejaNotificacionesScreenState();
}

class _BandejaNotificacionesScreenState extends ConsumerState<BandejaNotificacionesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificacionesControllerProvider.notifier).cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(notificacionesControllerProvider);
    final notifier = ref.read(notificacionesControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          if (estado.noLeidas > 0)
            TextButton.icon(
              onPressed: estado.marcandoTodas ? null : () => notifier.marcarTodasLeidas(),
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Marcar todas'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barra de filtros: Todas vs No leídas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GpSpacing.page, vertical: 8),
              child: Row(
                children: [
                  ChoiceChip(
                    label: Text('Todas (${estado.total})'),
                    selected: !estado.soloNoLeidas,
                    onSelected: (selected) {
                      if (selected) {
                        notifier.cambiarFiltro(false);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('No leídas'),
                        if (estado.noLeidas > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? GpColors.primarioClaro : GpColors.primario,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${estado.noLeidas}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    selected: estado.soloNoLeidas,
                    onSelected: (selected) {
                      if (selected) {
                        notifier.cambiarFiltro(true);
                      }
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Contenido principal
            Expanded(
              child: _buildContenido(estado, notifier),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContenido(NotificacionesState estado, NotificacionesController notifier) {
    if (estado.cargando && estado.notificaciones.isEmpty) {
      return const AppLoadingView();
    }

    if (estado.error != null && estado.notificaciones.isEmpty) {
      return AppErrorView(
        message: 'No pudimos cargar tus notificaciones.',
        onRetry: () => notifier.refrescar(),
      );
    }

    if (estado.notificaciones.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => notifier.refrescar(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 60),
            AppEmptyView(
              message: estado.soloNoLeidas
                  ? 'No tienes notificaciones sin leer.'
                  : 'Aún no tienes notificaciones en tu bandeja.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => notifier.refrescar(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: GpSpacing.page, vertical: 12),
        itemCount: estado.notificaciones.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = estado.notificaciones[index];
          return Dismissible(
            key: ValueKey('notif_${item.id}'),
            direction: item.leida ? DismissDirection.none : DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: GpColors.exito,
                borderRadius: BorderRadius.circular(GpRadii.tarjeta),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.mark_email_read, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Marcar como leída',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            confirmDismiss: (direction) async {
              await notifier.marcarLeida(item.id);
              return false; // Permite que el StateNotifier actualice la lista de forma reactiva
            },
            child: item.esRechazadaOFallida
                ? _TarjetaNotificacionRechazada(
                    item: item,
                    onTap: () => _abrirNotificacion(item),
                    onMarcarLeida: () => notifier.marcarLeida(item.id),
                  )
                : _TarjetaNotificacionEstandar(
                    item: item,
                    onTap: () => _abrirNotificacion(item),
                    onMarcarLeida: () => notifier.marcarLeida(item.id),
                  ),
          );
        },
      ),
    );
  }

  void _abrirNotificacion(NotificacionItem item) {
    if (!item.leida) {
      ref.read(notificacionesControllerProvider.notifier).marcarLeida(item.id);
    }
    if (item.transaccionId != null && item.transaccionId! > 0) {
      context.push('/comprobante/${item.transaccionId}');
    }
  }
}

/// Tarjeta destacada en ROJO para transacciones rechazadas o fallidas.
/// Cumple con los requerimientos clave:
/// 1. Por qué se rechazó (motivo claro)
/// 2. Código de error de GestoPago (ej. 'GestoPago: ERR-XX')
/// 3. Aclaración del estado del saldo
class _TarjetaNotificacionRechazada extends StatelessWidget {
  const _TarjetaNotificacionRechazada({
    required this.item,
    required this.onTap,
    required this.onMarcarLeida,
  });

  final NotificacionItem item;
  final VoidCallback onTap;
  final VoidCallback onMarcarLeida;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorError = isDark ? GpColors.errorOscuro : GpColors.error;
    final colorFondo = isDark
        ? const Color(0xFF2D1214)
        : GpColors.errorClaro.withValues(alpha: 0.35);

    final fechaFormateada = _formatearFecha(item.createdAt);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GpRadii.tarjeta),
        child: Container(
          decoration: BoxDecoration(
            color: colorFondo,
            borderRadius: BorderRadius.circular(GpRadii.tarjeta),
            border: Border.all(
              color: colorError.withValues(alpha: item.leida ? 0.4 : 0.9),
              width: item.leida ? 1.0 : 1.5,
            ),
            boxShadow: [
              if (!item.leida)
                BoxShadow(
                  color: colorError.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior: Chip de Alerta, Indicador no leída, Fecha
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colorError.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: colorError.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 14, color: colorError),
                        const SizedBox(width: 4),
                        Text(
                          item.estado ?? 'RECHAZADO',
                          style: TextStyle(
                            color: colorError,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Código de error de GestoPago destacado
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black45 : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: colorError.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      'GestoPago: ${item.codigoErrorGestoPago ?? 'ERR-RECHAZO'}',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: colorError,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (!item.leida)
                    Container(
                      width: 9,
                      height: 9,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: colorError,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Text(
                    fechaFormateada,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Título y servicio/producto
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.servicio != null && item.servicio!.isNotEmpty) ...[
                    BrandMark(servicio: item.servicio!, tamano: 36, radio: 10),
                    const SizedBox(width: 10),
                  ] else ...[
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colorError.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.cancel_outlined, color: colorError, size: 20),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.titulo.isNotEmpty ? item.titulo : 'Pago rechazado',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorError,
                          ),
                        ),
                        if (item.servicio != null && item.servicio!.isNotEmpty)
                          Text(
                            '${item.servicio} - ${item.producto ?? ''}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Cuerpo explicativo de la notificación
              if (item.cuerpo.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    item.cuerpo,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),

              // 1. Por qué se rechazó (motivo claro)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black38 : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorError.withValues(alpha: 0.25)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.report_problem_outlined, size: 16, color: colorError),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Motivo del rechazo: ',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            TextSpan(text: item.motivoExplicado),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // 2. Aclaración del estado del saldo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 16,
                      color: isDark ? GpColors.exitoOscuro : GpColors.exito,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Estado del saldo: ',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            TextSpan(text: item.aclaracionSaldo),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Botones de acción al pie de la tarjeta
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!item.leida)
                    TextButton(
                      onPressed: onMarcarLeida,
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text('Marcar leída'),
                    ),
                  if (item.transaccionId != null && item.transaccionId! > 0) ...[
                    const SizedBox(width: 6),
                    FilledButton.tonalIcon(
                      onPressed: onTap,
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        backgroundColor: colorError.withValues(alpha: 0.15),
                        foregroundColor: colorError,
                      ),
                      icon: const Icon(Icons.receipt_long, size: 16),
                      label: const Text('Ver comprobante'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta estándar para notificaciones informativas o exitosas.
class _TarjetaNotificacionEstandar extends StatelessWidget {
  const _TarjetaNotificacionEstandar({
    required this.item,
    required this.onTap,
    required this.onMarcarLeida,
  });

  final NotificacionItem item;
  final VoidCallback onTap;
  final VoidCallback onMarcarLeida;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final esExito = item.estado == 'LIQUIDADO' || item.titulo.toLowerCase().contains('exitoso');
    final fechaFormateada = _formatearFecha(item.createdAt);

    return Material(
      color: theme.cardTheme.color ?? scheme.surface,
      borderRadius: BorderRadius.circular(GpRadii.tarjeta),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GpRadii.tarjeta),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GpRadii.tarjeta),
            border: Border.all(
              color: item.leida ? scheme.outline : scheme.primary.withValues(alpha: 0.5),
              width: item.leida ? 1.0 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior: Estado, no leída, fecha
              Row(
                children: [
                  if (item.estado != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: esExito
                            ? (isDark ? GpColors.exitoOscuro.withValues(alpha: 0.15) : GpColors.exitoClaro)
                            : scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.estado!,
                        style: TextStyle(
                          color: esExito
                              ? (isDark ? GpColors.exitoOscuro : GpColors.exito)
                              : scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (!item.leida)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Text(
                    fechaFormateada,
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Contenido con BrandMark
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.servicio != null && item.servicio!.isNotEmpty) ...[
                    BrandMark(servicio: item.servicio!, tamano: 38, radio: 11),
                    const SizedBox(width: 12),
                  ] else ...[
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        esExito ? Icons.check_circle_outline : Icons.notifications_active_outlined,
                        color: esExito ? GpColors.exito : scheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.titulo,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: item.leida ? FontWeight.w600 : FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.cuerpo,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: item.leida ? scheme.onSurfaceVariant : scheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Botones de acción
              if (!item.leida || (item.transaccionId != null && item.transaccionId! > 0)) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!item.leida)
                      TextButton(
                        onPressed: onMarcarLeida,
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text('Marcar leída'),
                      ),
                    if (item.transaccionId != null && item.transaccionId! > 0) ...[
                      const SizedBox(width: 6),
                      TextButton.icon(
                        onPressed: onTap,
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.receipt_long, size: 16),
                        label: const Text('Ver comprobante'),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _formatearFecha(DateTime? fecha) {
  if (fecha == null) return '';
  final local = fecha.toLocal();
  final ahora = DateTime.now();
  final diferencia = ahora.difference(local);

  if (diferencia.inMinutes < 1) {
    return 'Hace un momento';
  } else if (diferencia.inHours < 1) {
    return 'Hace ${diferencia.inMinutes} m';
  } else if (diferencia.inDays < 1 && ahora.day == local.day) {
    return DateFormat('HH:mm').format(local);
  } else if (diferencia.inDays < 2) {
    return 'Ayer, ${DateFormat('HH:mm').format(local)}';
  } else {
    return DateFormat('d MMM, HH:mm').format(local);
  }
}
