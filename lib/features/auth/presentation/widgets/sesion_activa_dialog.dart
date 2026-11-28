import 'package:flutter/material.dart';

import '../../../../core/format/gp_fecha.dart';
import '../../../../core/theme/gp_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/desafio_mfa.dart';

/// Pide confirmación explícita antes de cerrar la sesión abierta en otro
/// canal. Devuelve true si el usuario decide cerrarla y continuar.
Future<bool?> mostrarSesionActivaDialog(BuildContext context, SesionActivaInfo info) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => SesionActivaDialog(info: info),
  );
}

class SesionActivaDialog extends StatelessWidget {
  const SesionActivaDialog({super.key, required this.info});

  final SesionActivaInfo info;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tema = Theme.of(context);
    const ambar = Color(0xFFB45309);
    final actividad = info.ultimaActividad;
    return AlertDialog(
      // Desplazable: en teléfonos pequeños o con texto ampliado no cabe completo.
      scrollable: true,
      icon: const Icon(Icons.devices_other_rounded, color: ambar, size: 32),
      title: Text(l.sessionActiveTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(GpSpacing.md),
            decoration: BoxDecoration(
              color: ambar.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(GpRadii.campo),
              border: Border.all(color: ambar.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                Icon(info.esWeb ? Icons.computer_rounded : Icons.smartphone_rounded, color: ambar),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(info.esWeb ? l.sessionActiveWeb : l.sessionActiveMobile, style: tema.textTheme.titleSmall),
                      Text(info.descripcionDispositivo, style: tema.textTheme.bodySmall),
                      if (actividad != null)
                        Text(
                          l.sessionActiveLastActivity(formatFecha(actividad.toUtc().toIso8601String())),
                          style: tema.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(l.sessionActiveMessage),
          const SizedBox(height: 12),
          Text(l.sessionActiveNotYou, style: tema.textTheme.bodySmall?.copyWith(color: ambar)),
        ],
      ),
      actionsOverflowDirection: VerticalDirection.up,
      actionsOverflowButtonSpacing: 8,
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l.commonCancel)),
        FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l.sessionActiveConfirm)),
      ],
    );
  }
}
