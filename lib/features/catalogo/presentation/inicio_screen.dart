import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/gp_assets.dart';
import '../../../core/theme/gp_colors.dart';
import '../../../core/theme/gp_theme.dart';
import '../../../core/widgets/app_empty_view.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/application/session_controller.dart';
import '../../pagos/application/pago_controller.dart';
import '../../pagos/domain/transaccion.dart';
import '../application/catalogo_controller.dart';
import '../domain/catalogo_producto.dart';
import '../domain/categoria_servicio.dart';
import '../domain/servicios_frecuentes.dart';
import '../presentation/widgets/selector_servicios_modal.dart';
import '../presentation/widgets/servicio_card.dart';

/// Inicio: saludo, búsqueda, acceso rápido a los servicios más usados y
/// recientes, y el catálogo completo.
class InicioScreen extends ConsumerStatefulWidget {
  const InicioScreen({super.key});

  @override
  ConsumerState<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends ConsumerState<InicioScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _iniciales(String nombre) {
    final partes =
        nombre.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (partes.isEmpty) {
      return 'GP';
    }
    if (partes.length == 1) {
      return partes.first.characters.first.toUpperCase();
    }
    return '${partes.first.characters.first}${partes.last.characters.first}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sesion = ref.watch(sessionControllerProvider);
    final catalogo = ref.watch(catalogoControllerProvider);

    final nombreSesion = sesion.session?.nombre;
    final nombre = (nombreSesion != null && nombreSesion.trim().isNotEmpty)
        ? nombreSesion
        : null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(GpSpacing.page, 12, GpSpacing.page, 12),
              child: _BannerInicio(
                nombre: nombre,
                mostrarSaludo: nombre != null,
                onIniciales: _iniciales,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(GpSpacing.page, 4, GpSpacing.page, 12),
              child: Material(
                elevation: 0,
                shadowColor: Colors.transparent,
                borderRadius: BorderRadius.circular(GpRadii.campo),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(GpRadii.campo),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: l.catalogSearchHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            ),
                    ),
                  ),
                ),
              ),
            ),
            catalogo.when(
              data: (productos) => _ContenidoCatalogo(
                productos: productos,
                busqueda: _searchController.text.trim().toLowerCase(),
              ),
              loading: () => const Expanded(child: AppLoadingView()),
              error: (error, stack) => Expanded(
                child: AppErrorView(
                  message: l.catalogError,
                  onRetry: () => ref.read(catalogoControllerProvider.notifier).refresh(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Contenido principal: Búsqueda activa O vista estructurada con Categorías,
/// Marcas más usadas y Actividad reciente.
class _ContenidoCatalogo extends ConsumerStatefulWidget {
  const _ContenidoCatalogo({
    required this.productos,
    required this.busqueda,
  });

  final List<CatalogoProducto> productos;
  final String busqueda;

  @override
  ConsumerState<_ContenidoCatalogo> createState() => _ContenidoCatalogoState();
}

class _ContenidoCatalogoState extends ConsumerState<_ContenidoCatalogo> {
  List<CatalogoProducto> get _filtrados {
    final query = widget.busqueda.trim().toLowerCase();
    if (query.isEmpty) return const [];
    return widget.productos.where((p) {
      return p.producto.toLowerCase().contains(query) ||
          p.servicio.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final query = widget.busqueda.trim();

    // 1. Si hay búsqueda activa: mostrar los resultados filtrados
    if (query.isNotEmpty) {
      final resultados = _filtrados;
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GpSpacing.page, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Resultados para "$query"',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    '${resultados.length} encontrados',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            if (resultados.isEmpty)
              Expanded(child: AppEmptyView(message: l.catalogEmpty))
            else
              Expanded(
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    GpSpacing.page,
                    4,
                    GpSpacing.page,
                    24,
                  ),
                  itemCount: resultados.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final producto = resultados[index];
                    return ServicioCard(
                      producto: producto,
                      onTap: () => context.push(
                        '/pago/${producto.idServicio}/${producto.idProducto}',
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      );
    }

    // 2. Vista principal optimizada (sin lista pesada de 500 productos)
    final frecuentes = productosFrecuentes(widget.productos);
    final historial = ref.watch(historialControllerProvider);
    final ultimasTransacciones = historial.value?.take(3).toList() ?? [];

    return Expanded(
      child: RefreshIndicator(
        onRefresh: () => ref.read(catalogoControllerProvider.notifier).refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            // Categorías de servicios (Grid visual)
            _EncabezadoSeccion(titulo: 'Categorías de servicios'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GpSpacing.page),
              child: _GridCategorias(
                onSeleccionar: (cat) => SelectorServiciosModal.mostrarCategoria(
                  context,
                  categoria: cat,
                  catalogo: widget.productos,
                ),
              ),
            ),

            // Los más usados (Marcas populares con logo oficial)
            if (frecuentes.isNotEmpty) ...[
              const SizedBox(height: 12),
              _EncabezadoSeccion(titulo: l.homeSectionPopular),
              _FilaAccesoRapido(
                children: [
                  for (final producto in frecuentes)
                    _TarjetaAcceso(
                      titulo: producto.servicio,
                      servicio: producto.servicio,
                      onTap: () {
                        final comp = obtenerCompaniaPorNombre(
                          widget.productos,
                          producto.servicio,
                        );
                        if (comp != null && comp.productos.length > 1) {
                          SelectorServiciosModal.mostrarCompania(
                            context,
                            compania: comp,
                            catalogo: widget.productos,
                          );
                        } else {
                          context.push(
                            '/pago/${producto.idServicio}/${producto.idProducto}',
                          );
                        }
                      },
                    ),
                ],
              ),
            ],

            // Últimos pagos realizados / Actividad reciente
            const SizedBox(height: 12),
            _EncabezadoSeccion(
              titulo: 'Actividad reciente',
              accion: ultimasTransacciones.isNotEmpty
                  ? TextButton(
                      onPressed: () => context.go('/historial'),
                      child: const Text('Ver historial'),
                    )
                  : null,
            ),
            if (ultimasTransacciones.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: GpSpacing.page, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(GpRadii.tarjeta),
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 36,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sin pagos recientes',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tus comprobantes y transacciones aparecerán aquí.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: GpSpacing.page),
                child: Column(
                  children: [
                    for (final tx in ultimasTransacciones)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TarjetaPagoReciente(
                          transaccion: tx,
                          onTap: () => context.push('/comprobante/${tx.id}'),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Grid de categorías de servicios con iconos modernos
class _GridCategorias extends StatelessWidget {
  const _GridCategorias({required this.onSeleccionar});

  final ValueChanged<CategoriaServicio> onSeleccionar;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final categorias = CategoriaServicio.categorias;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.15,
      ),
      itemCount: categorias.length,
      itemBuilder: (context, index) {
        final cat = categorias[index];
        return Material(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => onSeleccionar(cat),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: scheme.outline),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cat.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(cat.icono, color: cat.color, size: 24),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat.titulo,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

/// Tarjeta limpia para los últimos pagos en la pantalla principal
class _TarjetaPagoReciente extends StatelessWidget {
  const _TarjetaPagoReciente({
    required this.transaccion,
    required this.onTap,
  });

  final Transaccion transaccion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(GpRadii.tarjeta),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GpRadii.tarjeta),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GpRadii.tarjeta),
            border: Border.all(color: scheme.outline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              BrandMark(
                servicio: transaccion.servicio,
                tamano: 44,
                radio: 13,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaccion.producto,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ref. ${transaccion.referencia}',
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${transaccion.monto}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: scheme.primary,
                        ),
                  ),
                  const SizedBox(height: 2),
                  const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EncabezadoSeccion extends StatelessWidget {
  const _EncabezadoSeccion({required this.titulo, this.accion});

  final String titulo;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(GpSpacing.page, 8, GpSpacing.page, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titulo,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          if (accion != null) accion!,
        ],
      ),
    );
  }
}

class _FilaAccesoRapido extends StatelessWidget {
  const _FilaAccesoRapido({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 106,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: GpSpacing.page),
        itemCount: children.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, index) => children[index],
      ),
    );
  }
}

class _TarjetaAcceso extends StatelessWidget {
  const _TarjetaAcceso({
    required this.titulo,
    required this.servicio,
    required this.onTap,
  });

  final String titulo;
  final String servicio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            BrandMark(servicio: servicio, tamano: 48, radio: 15),
            const SizedBox(height: 8),
            Text(
              titulo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerInicio extends StatelessWidget {
  const _BannerInicio({
    required this.nombre,
    required this.mostrarSaludo,
    required this.onIniciales,
  });

  final String? nombre;
  final bool mostrarSaludo;
  final String Function(String) onIniciales;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(GpRadii.tarjeta),
      child: Container(
        height: 168,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(GpRadii.tarjeta),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E3A8A),
              Color(0xFF1D4ED8),
            ],
            stops: [0.0, 0.55, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1D4ED8).withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: -40,
              right: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF38BDF8).withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(child: SizedBox.shrink()),
                      if (mostrarSaludo)
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
                          child: Text(
                            onIniciales(nombre!),
                            style: TextStyle(
                              color: scheme.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  if (mostrarSaludo) ...[
                    Text(
                      l.homeGreeting(nombre!),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.homeWelcome,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ] else ...[
                    Text(
                      l.homeWelcome,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.homeCatalog,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}