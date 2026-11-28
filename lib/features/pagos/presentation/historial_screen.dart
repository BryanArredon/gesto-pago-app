import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/format/gp_fecha.dart';
import '../../../core/format/gp_money.dart';
import '../../../core/theme/gp_theme.dart';
import '../../../core/widgets/app_empty_view.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/esqueleto.dart';
import '../../../core/widgets/money_text.dart';
import '../../../l10n/app_localizations.dart';
import '../application/pago_controller.dart';
import '../domain/estado_transaccion.dart';
import '../domain/transaccion.dart';
import 'widgets/estado_transaccion_badge.dart';

class HistorialScreen extends ConsumerWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final historial = ref.watch(historialControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.historialTitle)),
      body: historial.when(
        loading: () => EsqueletoLista(etiqueta: l.commonLoading),
        error: (error, stack) => AppErrorView(
          message: l.historialError,
          onRetry: () => ref.read(historialControllerProvider.notifier).refresh(),
        ),
        data: (todas) {
          // Solo las operaciones confirmadas como exitosas (LIQUIDADO) son compras
          // realizadas. Las demás siguen disponibles en su comprobante.
          final transacciones = todas.where((t) => t.esAprobada).toList()
            ..sort((a, b) => b.fecha.compareTo(a.fecha));
          if (transacciones.isEmpty) {
            return AppEmptyView(message: l.historialEmpty);
          }
          final grupos = _agruparPorMes(transacciones, Localizations.localeOf(context).toLanguageTag());
          final total = transacciones.fold<double>(0, (s, t) => s + (double.tryParse(t.monto) ?? 0));

          return RefreshIndicator(
            onRefresh: () => ref.read(historialControllerProvider.notifier).refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(GpSpacing.page, 8, GpSpacing.page, 24),
              children: [
                Text(l.historialSoloExitosas, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _Resumen(etiqueta: l.historialResumenCompras, valor: '${transacciones.length}')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Resumen(etiqueta: l.historialResumenTotal, valor: GpMoney.format(total.toStringAsFixed(2))),
                    ),
                  ],
                ),
                for (final (mes, txs) in grupos) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 24, 4, 10),
                    child: Semantics(
                      header: true,
                      child: Text(
                        mes.toUpperCase(),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          letterSpacing: 1.1,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  for (final tx in txs) ...[
                    _ItemHistorial(transaccion: tx, onTap: () => context.push('/comprobante/${tx.id}')),
                    const SizedBox(height: 10),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Agrupa por "mes año" conservando el orden (más reciente primero).
List<(String, List<Transaccion>)> _agruparPorMes(List<Transaccion> txs, String locale) {
  final formato = DateFormat('MMMM yyyy', locale);
  final grupos = <String, List<Transaccion>>{};
  for (final tx in txs) {
    final fecha = DateTime.tryParse(tx.fecha)?.toLocal();
    final clave = fecha == null ? '—' : formato.format(fecha);
    grupos.putIfAbsent(clave, () => []).add(tx);
  }
  return [for (final e in grupos.entries) (e.key, e.value)];
}

class _Resumen extends StatelessWidget {
  const _Resumen({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      label: '$etiqueta: $valor',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(GpSpacing.lg),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(GpRadii.tarjeta),
            border: Border.all(color: scheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(etiqueta, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(
                valor,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemHistorial extends ConsumerWidget {
  const _ItemHistorial({required this.transaccion, required this.onTap});

  final Transaccion transaccion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final etiquetaEstado = switch (transaccion.estado) {
      EstadoTransaccion.aprobada => l.historialStateApproved,
      EstadoTransaccion.fallida => l.historialStateFailed,
      EstadoTransaccion.enProceso => l.historialStateProcessing,
      EstadoTransaccion.pendiente => l.historialStatePending,
    };

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(GpRadii.tarjeta),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GpRadii.tarjeta),
        child: Container(
          padding: const EdgeInsets.all(GpSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GpRadii.tarjeta),
            border: Border.all(color: scheme.outline),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 6)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BrandMark(servicio: transaccion.servicio, tamano: 40, radio: 12),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      transaccion.producto,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  EstadoTransaccionBadge(estado: transaccion.estado, label: etiquetaEstado),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ref ${transaccion.referencia}', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 2),
                      Text(formatFecha(transaccion.fecha), style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  MoneyText(monto: transaccion.monto, style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
