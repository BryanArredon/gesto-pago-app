import 'package:flutter/material.dart';

import '../theme/gp_assets.dart';
import '../utils/texto.dart';

/// Insignia cuadrada con el logo real de la marca del producto sobre una
/// ficha blanca redondeada. Si el logo no está disponible, muestra el ícono
/// de la categoría con fondo neutro.
class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    required this.servicio,
    this.categoria,
    this.tamano = 48,
    this.radio = 14,
  });

  final String servicio;
  final int? categoria;
  final double tamano;
  final double radio;

  String? _asset() {
    final slug = slugTexto(servicio);
    final exacta = GpAssets.marcas[slug];
    if (exacta != null) {
      return exacta;
    }
    // Nombres con separadores o sufijos (p. ej. "AT-T", "Xbox Game Pass Core",
    // "Netflix Premium"): usar el logo de la marca más específica contenida,
    // ignorando guiones/espacios.
    final base = slug.replaceAll('_', '');
    String? mejor;
    var mejorLongitud = 0;
    for (final entry in GpAssets.marcas.entries) {
      if (base.contains(entry.key.replaceAll('_', '')) &&
          entry.key.length > mejorLongitud) {
        mejor = entry.value;
        mejorLongitud = entry.key.length;
      }
    }
    return mejor;
  }

  IconData get _icono {
    return switch (categoria) {
      7 => Icons.account_balance_outlined,
      15 => Icons.water_drop_outlined,
      _ => Icons.receipt_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final asset = _asset();

    final contenido = asset != null
        ? SizedBox.expand(
            child: Image.asset(
              asset,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => _IconoCategoria(
                icono: _icono,
                tamano: tamano,
                radio: radio,
              ),
            ),
          )
        : _IconoCategoria(
            icono: _icono,
            tamano: tamano,
            radio: radio,
          );

    return Container(
      width: tamano,
      height: tamano,
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radio),
        border: Border.all(color: scheme.outline, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: contenido,
    );
  }
}

class _IconoCategoria extends StatelessWidget {
  const _IconoCategoria({
    required this.icono,
    required this.tamano,
    required this.radio,
  });

  final IconData icono;
  final double tamano;
  final double radio;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radio),
      ),
      child: Icon(icono, color: scheme.onSurfaceVariant, size: tamano * 0.5),
    );
  }
}