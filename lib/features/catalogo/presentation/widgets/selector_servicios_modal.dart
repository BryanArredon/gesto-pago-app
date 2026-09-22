import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/gp_colors.dart';
import '../../../../core/theme/gp_theme.dart';
import '../../../../core/widgets/brand_mark.dart';
import '../../../../core/widgets/money_text.dart';
import '../../domain/catalogo_producto.dart';
import '../../domain/categoria_servicio.dart';

/// Modal BottomSheet interactivo que gestiona la selección de compañías y
/// sus productos/montos disponibles con una experiencia organizada por pestañas y buscador.
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
    final maxH = MediaQuery.of(context).size.height * 0.88;

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
                    )
                  else if (_companiaSeleccionada != null)
                    BrandMark(
                      servicio: _companiaSeleccionada!.nombre,
                      tamano: 36,
                      radio: 10,
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
                              ? '${_companiaSeleccionada!.productos.length} opciones disponibles'
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
                      key: ValueKey(_companiaSeleccionada!.slug),
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
                          setState(() {
                            _companiaSeleccionada = comp;
                            _filtroController.clear();
                          });
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

/// Nivel 1: Lista de compañías consolidadas dentro de una categoría
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
                              : 'Pago directo',
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

/// Nivel 2: Productos de la compañía con pestañas por subcategoría y detalles limpios
class _VistaProductosCompania extends StatefulWidget {
  const _VistaProductosCompania({
    super.key,
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
  late String _subgrupoSeleccionado;

  @override
  void initState() {
    super.initState();
    final subgrupos = widget.compania.subgrupos;
    _subgrupoSeleccionado = subgrupos.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final subgrupos = widget.compania.subgrupos;
    final query = widget.filtroController.text.trim().toLowerCase();

    // Obtener productos según el subgrupo activo
    final productosBase = subgrupos[_subgrupoSeleccionado] ?? widget.compania.productos;

    // Filtrar por texto de búsqueda si el usuario escribe
    final productosFiltrados = productosBase.where((p) {
      if (query.isEmpty) return true;
      final texto = '${p.producto} ${p.servicio} ${p.precio} ${p.legend ?? ''}'.toLowerCase();
      return texto.contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Buscador si la compañía tiene más de 5 productos
        if (widget.compania.productos.length > 5)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: widget.filtroController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar por monto, paquete o vigencia...',
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

        // 2. Filtros de Subcategorías (Chips horizontales si hay más de 1 subgrupo)
        if (subgrupos.length > 1)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: subgrupos.entries.map((entry) {
                final nombre = entry.key;
                final total = entry.value.length;
                final activo = nombre == _subgrupoSeleccionado;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: activo,
                    label: Text('$nombre ($total)'),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
                      color: activo ? Colors.white : scheme.onSurface,
                    ),
                    selectedColor: scheme.primary,
                    checkmarkColor: Colors.white,
                    backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: activo ? scheme.primary : scheme.outline,
                      ),
                    ),
                    onSelected: (_) {
                      setState(() {
                        _subgrupoSeleccionado = nombre;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

        const SizedBox(height: 4),

        // 3. Lista de productos limpios sin iconos repetitivos ni recuadros extras
        Expanded(
          child: productosFiltrados.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded, size: 40, color: scheme.outline),
                        const SizedBox(height: 8),
                        Text(
                          'No hay opciones que coincidan.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                  itemCount: productosFiltrados.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final prod = productosFiltrados[index];
                    final precioNum = double.tryParse(prod.precio) ?? 0.0;
                    final tieneDescripcion = prod.legend != null && prod.legend!.trim().isNotEmpty;
                    final precioEnTitulo = precioNum > 0 &&
                        (prod.producto.contains('\$${precioNum.toInt()}') ||
                         prod.producto.contains('\$${prod.precio}') ||
                         RegExp(r'\b' + precioNum.toInt().toString() + r'\b').hasMatch(prod.producto));

                    return Material(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(GpRadii.tarjeta),
                      child: InkWell(
                        onTap: () => widget.onSeleccionar(prod),
                        borderRadius: BorderRadius.circular(GpRadii.tarjeta),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(GpRadii.tarjeta),
                            border: Border.all(color: scheme.outline),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Título del producto y Descripción limpia como texto normal
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      prod.producto,
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14.5,
                                            height: 1.25,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      tieneDescripcion
                                          ? prod.legend!.trim()
                                          : (prod.esPrecioFinal ? 'Recarga prepago' : 'Pago de servicio'),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                            fontSize: 12.5,
                                            height: 1.25,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 14),

                              // Precio único (solo si NO está en el título) y flecha de acción
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (precioNum > 0 && !precioEnTitulo)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: MoneyText(
                                        monto: prod.precio,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: scheme.primary,
                                              fontSize: 16,
                                            ),
                                        negritas: true,
                                      ),
                                    ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
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
