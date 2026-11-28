import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/gp_fecha.dart';
import '../../../core/format/gp_money.dart';
import '../../../core/theme/gp_assets.dart';
import '../../../core/theme/gp_colors.dart';
import '../../../core/theme/gp_theme.dart';
import '../../../core/widgets/money_text.dart';
import '../../../l10n/app_localizations.dart';
import '../application/pago_controller.dart';
import '../domain/estado_transaccion.dart';
import '../domain/transaccion.dart';
import 'compartir_comprobante.dart';
import 'widgets/estado_transaccion_badge.dart';

/// Comprobante de una transacción. Para estados no definitivos permite
/// volver a consultar el resultado con el proveedor.
class ComprobanteScreen extends ConsumerStatefulWidget {
  const ComprobanteScreen({super.key, required this.transaccionId});

  final int transaccionId;

  @override
  ConsumerState<ComprobanteScreen> createState() => _ComprobanteScreenState();
}

class _ComprobanteScreenState extends ConsumerState<ComprobanteScreen> {
  bool _intentoCargaHistorial = false;
  bool _compartiendo = false;

  /// Marca el "ticket" en pantalla para capturarlo como imagen.
  final _ticket = GlobalKey();

  Transaccion? _resolver(WidgetRef ref) {
    final delFlujo = ref.watch(pagoControllerProvider).transaccion;
    if (delFlujo != null && delFlujo.id == widget.transaccionId) {
      return delFlujo;
    }
    final historial = ref.watch(historialControllerProvider);
    if (historial.value == null) {
      if (!_intentoCargaHistorial) {
        _intentoCargaHistorial = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(historialControllerProvider.notifier).refresh();
          }
        });
      }
      return null;
    }
    for (final tx in historial.value!) {
      if (tx.id == widget.transaccionId) {
        return tx;
      }
    }
    return null;
  }

  Future<void> _elegirFormato(Transaccion tx, Rect? origen) async {
    final l = AppLocalizations.of(context);
    final formato = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (hoja) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                l.comprobanteCompartir,
                style: Theme.of(hoja).textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: Text(l.comprobanteCompartirImagen),
              subtitle: Text(l.comprobanteCompartirImagenDetalle),
              onTap: () => Navigator.of(hoja).pop('png'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: Text(l.comprobanteCompartirPdf),
              subtitle: Text(l.comprobanteCompartirPdfDetalle),
              onTap: () => Navigator.of(hoja).pop('pdf'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (formato == null || !mounted) {
      return;
    }
    final mensajero = ScaffoldMessenger.of(context);
    setState(() => _compartiendo = true);
    try {
      final Uint8List bytes;
      final String tipo;
      if (formato == 'pdf') {
        bytes = await CompartirComprobante.pdf(tx, l);
        tipo = 'application/pdf';
      } else {
        bytes = await CompartirComprobante.imagen(_ticket);
        tipo = 'image/png';
      }
      await CompartirComprobante.compartir(
        bytes: bytes,
        nombre: CompartirComprobante.nombreArchivo(tx, formato),
        tipo: tipo,
        texto:
            '${l.comprobanteDocumento} · ${tx.producto} · ${GpMoney.format(tx.monto)}',
        origen: origen,
      );
    } catch (e) {
      unawaited(HapticFeedback.heavyImpact());
      mensajero.showSnackBar(
        SnackBar(content: Text(l.comprobanteCompartirError)),
      );
    } finally {
      if (mounted) {
        setState(() => _compartiendo = false);
      }
    }
  }

  Future<void> _consultar() async {
    await ref
        .read(pagoControllerProvider.notifier)
        .confirmarTransaccion(widget.transaccionId);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final estadoFlujo = ref.watch(pagoControllerProvider);
    final transaccion = _resolver(ref);
    final consultando = estadoFlujo.confirmando;

    if (transaccion == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.pagoReceipt)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final aprobada = transaccion.esAprobada;
    final fallida = transaccion.estado == EstadoTransaccion.fallida;
    final enProceso =
        transaccion.estado == EstadoTransaccion.enProceso ||
        transaccion.estado == EstadoTransaccion.pendiente;

    final titulo = aprobada
        ? l.pagoSuccess
        : fallida
        ? l.pagoFailed
        : l.pagoPending;

    // Solo una compra exitosa se comparte: un comprobante "pendiente" circulando se presta a confusión o fraude.
    final accionCompartir = aprobada
        ? Builder(
            builder: (boton) => IconButton(
              tooltip: l.comprobanteCompartir,
              onPressed: _compartiendo
                  ? null
                  : () {
                      final caja = boton.findRenderObject() as RenderBox?;
                      final origen = caja == null
                          ? null
                          : caja.localToGlobal(Offset.zero) & caja.size;
                      _elegirFormato(transaccion, origen);
                    },
              icon: _compartiendo
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.ios_share_rounded),
            ),
          )
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(l.pagoReceipt), actions: [?accionCompartir]),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GpSpacing.page),
          children: [
            // El ticket se dibuja como papel (tema claro) en ambos modos: así la imagen compartida
            // se ve igual que un comprobante impreso.
            RepaintBoundary(
              key: _ticket,
              child: Theme(
                data: GpTheme.light(),
                child: Builder(
                  builder: (context) => Container(
                    padding: const EdgeInsets.fromLTRB(
                      GpSpacing.lg,
                      24,
                      GpSpacing.lg,
                      GpSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(GpRadii.tarjeta),
                    ),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                color: aprobada
                                    ? GpColors.exitoClaro
                                    : fallida
                                    ? GpColors.errorClaro
                                    : GpColors.procesoClaro,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                aprobada
                                    ? Icons.check_rounded
                                    : fallida
                                    ? Icons.close_rounded
                                    : Icons.hourglass_top,
                                size: 76,
                                color: aprobada
                                    ? GpColors.exito
                                    : fallida
                                    ? GpColors.error
                                    : GpColors.proceso,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              titulo,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              transaccion.producto,
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        MoneyText(
                          monto: transaccion.monto,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(GpSpacing.lg),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(
                              GpRadii.tarjeta,
                            ),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          child: Column(
                            children: [
                              _Fila(
                                label: l.comprobanteEstado,
                                child: EstadoTransaccionBadge(
                                  estado: transaccion.estado,
                                  label: _etiquetaEstado(l, transaccion.estado),
                                ),
                              ),
                              _Fila(
                                label: l.comprobanteFecha,
                                child: Text(formatFecha(transaccion.fecha)),
                              ),
                              _Fila(
                                label: l.pagoConfirmReference,
                                child: Text(transaccion.referencia),
                              ),
                              if (transaccion.numeroAutorizacion.isNotEmpty)
                                _Fila(
                                  label: l.pagoAuthorization,
                                  child: Text(transaccion.numeroAutorizacion),
                                ),
                              if (transaccion.idTx.isNotEmpty)
                                _Fila(
                                  label: l.pagoTransactionId,
                                  child: Text(transaccion.idTx),
                                ),
                              if (transaccion.errorMensaje != null &&
                                  transaccion.errorMensaje!.isNotEmpty)
                                _Fila(
                                  label: 'Detalle',
                                  child: Text(transaccion.errorMensaje!),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              GpAssets.logo,
                              width: 18,
                              height: 18,
                              errorBuilder: (_, _, _) => const SizedBox(),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${l.comprobanteGenerado} · ID ${transaccion.id}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              enProceso ? l.pagoPending : (transaccion.legend ?? ''),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (enProceso)
              OutlinedButton.icon(
                onPressed: consultando ? null : _consultar,
                icon: consultando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
                label: Text(l.pagoCheckingResult),
              ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.go('/historial'),
              icon: const Icon(Icons.receipt_long_outlined),
              label: Text(l.pagoSeeHistory),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/home'),
              child: Text(l.comprobanteVolverInicio),
            ),
          ],
        ),
      ),
    );
  }

  String _etiquetaEstado(AppLocalizations l, EstadoTransaccion estado) {
    return switch (estado) {
      EstadoTransaccion.aprobada => l.historialStateApproved,
      EstadoTransaccion.fallida => l.historialStateFailed,
      EstadoTransaccion.enProceso => l.historialStateProcessing,
      EstadoTransaccion.pendiente => l.historialStatePending,
    };
  }
}

class _Fila extends StatelessWidget {
  const _Fila({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Align(alignment: Alignment.centerRight, child: child),
          ),
        ],
      ),
    );
  }
}
