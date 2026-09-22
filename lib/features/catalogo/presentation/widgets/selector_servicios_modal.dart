import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/gp_colors.dart';
import '../../../../core/theme/gp_theme.dart';
import '../../../../core/widgets/brand_mark.dart';
import '../../../../core/widgets/money_text.dart';
import '../domain/catalogo_producto.dart';
import '../domain/categoria_servicio.dart';

/// Modal BottomSheet interactivo que gestiona la selección de compañías y
/// sus productos/montos disponibles con una experiencia fluida.
class SelectorServiciosModal extends StatefulWidget {
  const SelectorServiciosModal({
    super.key,
    this.categoria,
    this.companiaInicial,
    required this.catalogo,
  });

  final CategoriaServicio? categoria;
  final CompaniaServicio? companiaInicial;
  final List<CatalogoProducto> catalogo;

  static Future<void> mostrarCategoria(
    BuildContext context, {
    required CategoriaServicio categoria,
    required List<CatalogoProducto> catalogo,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SelectorServiciosModal(
        categoria: categoria,
        catalogo: catalogo,
      ),
    );
  }

  static Future<void> mostrarCompania(
    BuildContext context, {
    required CompaniaServicio compania,
    required List<CatalogoProducto> catalogo,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SelectorServiciosModal(
        companiaInicial: compania,
        catalogo: catalogo,
      ),
    );
  }

  @override
  State<SelectorServiciosModal> createState() => _SelectorServiciosModalState();
}

class _SelectorServiciosModalState extends State<SelectorServiciosModal> {
  CompaniaServicio? _companiaSeleccionada;
  final _filtroController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _companiaSeleccionada = widget.companiaInicial;
  }

  @override
  void dispose() {
    _filtroController.dispose();
    super.dispose();
  }

  void _seleccionarProducto(CatalogoProducto producto) {
    Navigator.of(context).pop();
    context.push('/pago/${producto.idServicio}/${producto.idProducto}');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxH = MediaQuery.of(context).size.height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header con navegación de regreso si está en nivel de productos
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  if (_companiaSeleccionada != null && widget.categoria != null)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        setState(() {
                          _companiaSeleccionada = null;
                          _filtroController.clear();
                        });
                      },
                    )
                  else if (widget.categoria != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.categoria!.color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.categoria!.icono,
                        color: widget.categoria!.color,
                        size: 20,
                      ),
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _companiaSeleccionada != null
                              ? _companiaSeleccionada!.nombre
                              : (widget.categoria?.titulo ?? 'Servicios'),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _companiaSeleccionada != null
                              ? 'Selecciona el monto o paquete'
                              : 'Selecciona una compañía',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Contenido dinámico (Nivel 1: Compañías O Nivel 2: Productos)
            Flexible(
              child: _companiaSeleccionada != null
                  ? _VistaProductosCompania(
                      compania: _companiaSeleccionada!,
                      filtroController: _filtroController,
                      onSeleccionar: _seleccionarProducto,
                    )
                  : _VistaCompaniasCategoria(
                      categoria: widget.categoria!,
                      catalogo: widget.catalogo,
                      onSeleccionarCompania: (comp) {
                        if (comp.productos.length == 1) {
                          _seleccionarProducto(comp.productos.first);
                        } else {
                          setState(() => _companiaSeleccionada = comp);
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nivel 1: Lista de compañías dentro de una categoría
class _VistaCompaniasCategoria extends StatelessWidget {
  const _VistaCompaniasCategoria({
    required this.categoria,
    required this.catalogo,
    required this.onSeleccionarCompania,
  });

  final CategoriaServicio categoria;
  final List<CatalogoProducto> catalogo;
  final ValueChanged<CompaniaServicio> onSeleccionarCompania;

  @override
  Widget build(BuildContext context) {
    final companias = obtenerCompaniasPorCategoria(catalogo, categoria);
    final scheme = Theme.of(context).colorScheme;

    if (companias.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: scheme.outline),
            const SizedBox(height: 12),
            Text(
              'No hay servicios disponibles en esta categoría.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: companias.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final comp = companias[index];
        final totalOpciones = comp.productos.length;

        return Material(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(GpRadii.tarjeta),
          child: InkWell(
            onTap: () => onSeleccionarCompania(comp),
            borderRadius: BorderRadius.circular(GpRadii.tarjeta),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(GpRadii.tarjeta),
                border: Border.all(color: scheme.outline),
              ),
              child: Row(
                children: [
                  BrandMark(
                    servicio: comp.nombre,
                    tamano: 46,
                    radio: 14,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comp.nombre,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          totalOpciones > 1
                              ? '$totalOpciones paquetes / montos disponibles'
                              : 'Pago de servicio directo',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Nivel 2: Lista / Cuadrícula de productos de la compañía elegida
class _VistaProductosCompania extends StatefulWidget {
  const _VistaProductosCompania({
    required this.compania,
    required this.filtroController,
    required this.onSeleccionar,
  });

  final CompaniaServicio compania;
  final TextEditingController filtroController;
  final ValueChanged<CatalogoProducto> onSeleccionar;

  @override
  State<_VistaProductosCompania> createState() => _VistaProductosCompaniaState();
}

class _VistaProductosCompaniaState extends State<_VistaProductosCompania> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final query = widget.filtroController.text.trim().toLowerCase();

    final productosFiltrados = widget.compania.productos.where((p) {
      if (query.isEmpty) return true;
      return p.producto.toLowerCase().contains(query) ||
          p.precio.contains(query);
    }).toList();

    return Column(
      children: [
        // Buscador interno si la compañía tiene más de 6 productos
        if (widget.compania.productos.length > 6)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: widget.filtroController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Filtrar por monto o paquete...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                suffixIcon: widget.filtroController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          widget.filtroController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),

        // Lista de productos
        Expanded(
          child: productosFiltrados.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No hay productos que coincidan con la búsqueda.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: productosFiltrados.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final prod = productosFiltrados[index];
                    final precioNum = double.tryParse(prod.precio) ?? 0.0;

                    return Material(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(GpRadii.tarjeta),
                      child: InkWell(
                        onTap: () => widget.onSeleccionar(prod),
                        borderRadius: BorderRadius.circular(GpRadii.tarjeta),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(GpRadii.tarjeta),
                            border: Border.all(color: scheme.outline),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: GpColors.verde.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Icon(
                                    prod.esPrecioFinal
                                        ? Icons.phone_android_rounded
                                        : Icons.receipt_long_rounded,
                                    color: GpColors.verde,
                                    size: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      prod.producto,
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      prod.esPrecioFinal ? 'Recarga de saldo' : 'Pago por recibo',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (precioNum > 0)
                                    MoneyText(
                                      monto: prod.precio,
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: GpColors.verde,
                                          ),
                                      negritas: true,
                                    )
                                  else
                                    Text(
                                      'Monto libre',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: scheme.onSurfaceVariant,
                                          ),
                                    ),
                                  const SizedBox(height: 2),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 16,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
