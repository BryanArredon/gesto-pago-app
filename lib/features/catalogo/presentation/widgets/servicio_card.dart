import 'package:flutter/material.dart';

import '../../../../../core/theme/gp_theme.dart';
import '../../../../../core/widgets/brand_mark.dart';
import '../../../../../core/widgets/money_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/catalogo_producto.dart';

/// Tarjeta de un producto/servicio del catálogo con logo de marca.
class ServicioCard extends StatelessWidget {
  const ServicioCard({super.key, required this.producto, required this.onTap});

  final CatalogoProducto producto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final precioNum = double.tryParse(producto.precio) ?? 0.0;
    final precioEnTitulo = precioNum > 0 &&
        (producto.producto.contains('\$${precioNum.toInt()}') ||
         producto.producto.contains('\$${producto.precio}') ||
         RegExp(r'\b' + precioNum.toInt().toString() + r'\b').hasMatch(producto.producto));

    return Material(
      color: scheme.surface,
      elevation: 0,
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
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              BrandMark(
                servicio: producto.servicio,
                categoria: producto.idCatTipoServicio,
                tamano: 52,
                radio: 15,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.producto,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      producto.servicio,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (precioNum > 0 && !precioEnTitulo)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: MoneyText(
                        monto: producto.precio,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: scheme.primary,
                            ),
                        negritas: true,
                      ),
                    ),
                  Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}