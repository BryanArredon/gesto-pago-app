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
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      producto.servicio,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      producto.esPrecioFinal ? l.catalogPrice : l.catalogCommission,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MoneyText(
                    monto: producto.precio,
                    style: Theme.of(context).textTheme.titleMedium,
                    negritas: true,
                  ),
                  const SizedBox(height: 4),
                  Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}