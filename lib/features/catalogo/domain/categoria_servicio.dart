import 'package:flutter/material.dart';

import '../../../core/utils/texto.dart';
import 'catalogo_producto.dart';

/// Modelo de categoría de servicio para agrupación de alto nivel en la app.
class CategoriaServicio {
  const CategoriaServicio({
    required this.id,
    required this.titulo,
    required this.icono,
    required this.color,
    required this.marcas,
  });

  final String id;
  final String titulo;
  final IconData icono;
  final Color color;
  final List<String> marcas;

  static const List<CategoriaServicio> categorias = [
    CategoriaServicio(
      id: 'telefonia',
      titulo: 'Telefonía y Recargas',
      icono: Icons.phone_android_rounded,
      color: Color(0xFF0066FF),
      marcas: ['telcel', 'att', 'movistar', 'unefon', 'bait', 'pillofon', 'virgin'],
    ),
    CategoriaServicio(
      id: 'luz_agua_gas',
      titulo: 'Luz, Agua y Gas',
      icono: Icons.bolt_rounded,
      color: Color(0xFF008954),
      marcas: ['cfe', 'naturgy', 'zeta_gas', 'siapa', 'sacmex', 'agua', 'gas'],
    ),
    CategoriaServicio(
      id: 'internet_tv',
      titulo: 'Internet y Televisión',
      icono: Icons.wifi_rounded,
      color: Color(0xFF7C3AED),
      marcas: ['totalplay', 'izzi', 'megacable', 'sky', 'dish', 'telmex', 'axtel'],
    ),
    CategoriaServicio(
      id: 'telepeaje',
      titulo: 'Telepeaje y Casetas',
      icono: Icons.toll_rounded,
      color: Color(0xFF0D9488),
      marcas: ['pase', 'televia', 'iave', 'tag', 'viapass'],
    ),
    CategoriaServicio(
      id: 'streaming',
      titulo: 'Streaming y Música',
      icono: Icons.play_circle_filled_rounded,
      color: Color(0xFFE11D48),
      marcas: ['netflix', 'spotify', 'amazon', 'google_play', 'starbucks', 'apple'],
    ),
    CategoriaServicio(
      id: 'videojuegos',
      titulo: 'Videojuegos y Pines',
      icono: Icons.sports_esports_rounded,
      color: Color(0xFFEA580C),
      marcas: ['xbox', 'playstation', 'nintendo', 'roblox', 'free_fire', 'steam'],
    ),
  ];
}

/// Definición de una marca canónica para consolidar múltiples idServicios de la misma empresa
class _MarcaCanonica {
  const _MarcaCanonica({
    required this.slug,
    required this.nombreOficial,
    required this.categoriaId,
    required this.keywords,
  });

  final String slug;
  final String nombreOficial;
  final String categoriaId;
  final List<String> keywords;
}

const List<_MarcaCanonica> _marcasCanonicas = [
  // Telefonía
  _MarcaCanonica(
    slug: 'telcel',
    nombreOficial: 'Telcel',
    categoriaId: 'telefonia',
    keywords: ['telcel', 'amigo'],
  ),
  _MarcaCanonica(
    slug: 'movistar',
    nombreOficial: 'Movistar',
    categoriaId: 'telefonia',
    keywords: ['movistar'],
  ),
  _MarcaCanonica(
    slug: 'att',
    nombreOficial: 'AT&T',
    categoriaId: 'telefonia',
    keywords: ['att', 'at_t', 'iusacell', 'nextel'],
  ),
  _MarcaCanonica(
    slug: 'unefon',
    nombreOficial: 'Unefon',
    categoriaId: 'telefonia',
    keywords: ['unefon'],
  ),
  _MarcaCanonica(
    slug: 'bait',
    nombreOficial: 'Bait',
    categoriaId: 'telefonia',
    keywords: ['bait'],
  ),
  _MarcaCanonica(
    slug: 'pillofon',
    nombreOficial: 'Pillofon',
    categoriaId: 'telefonia',
    keywords: ['pillofon'],
  ),
  _MarcaCanonica(
    slug: 'virgin',
    nombreOficial: 'Virgin Mobile',
    categoriaId: 'telefonia',
    keywords: ['virgin'],
  ),

  // Luz, Agua y Gas
  _MarcaCanonica(
    slug: 'cfe',
    nombreOficial: 'CFE Suministrador',
    categoriaId: 'luz_agua_gas',
    keywords: ['cfe', 'luz', 'comision federal'],
  ),
  _MarcaCanonica(
    slug: 'naturgy',
    nombreOficial: 'Naturgy Gas',
    categoriaId: 'luz_agua_gas',
    keywords: ['naturgy', 'gas natural'],
  ),
  _MarcaCanonica(
    slug: 'zeta_gas',
    nombreOficial: 'Zeta Gas',
    categoriaId: 'luz_agua_gas',
    keywords: ['zeta_gas', 'zetagas', 'zeta'],
  ),
  _MarcaCanonica(
    slug: 'siapa',
    nombreOficial: 'SIAPA Agua',
    categoriaId: 'luz_agua_gas',
    keywords: ['siapa'],
  ),
  _MarcaCanonica(
    slug: 'sacmex',
    nombreOficial: 'SACMEX Agua',
    categoriaId: 'luz_agua_gas',
    keywords: ['sacmex'],
  ),

  // Internet y TV
  _MarcaCanonica(
    slug: 'totalplay',
    nombreOficial: 'Totalplay',
    categoriaId: 'internet_tv',
    keywords: ['totalplay'],
  ),
  _MarcaCanonica(
    slug: 'izzi',
    nombreOficial: 'Izzi Telecom',
    categoriaId: 'internet_tv',
    keywords: ['izzi'],
  ),
  _MarcaCanonica(
    slug: 'megacable',
    nombreOficial: 'Megacable',
    categoriaId: 'internet_tv',
    keywords: ['megacable'],
  ),
  _MarcaCanonica(
    slug: 'telmex',
    nombreOficial: 'Telmex',
    categoriaId: 'internet_tv',
    keywords: ['telmex'],
  ),
  _MarcaCanonica(
    slug: 'sky',
    nombreOficial: 'Sky / VeTV',
    categoriaId: 'internet_tv',
    keywords: ['sky', 'vetv'],
  ),
  _MarcaCanonica(
    slug: 'dish',
    nombreOficial: 'Dish México',
    categoriaId: 'internet_tv',
    keywords: ['dish'],
  ),

  // Telepeaje
  _MarcaCanonica(
    slug: 'pase',
    nombreOficial: 'PASE UrbanPass',
    categoriaId: 'telepeaje',
    keywords: ['pase', 'viapass'],
  ),
  _MarcaCanonica(
    slug: 'televia',
    nombreOficial: 'Televía',
    categoriaId: 'telepeaje',
    keywords: ['televia', 'tag'],
  ),

  // Streaming
  _MarcaCanonica(
    slug: 'netflix',
    nombreOficial: 'Netflix',
    categoriaId: 'streaming',
    keywords: ['netflix'],
  ),
  _MarcaCanonica(
    slug: 'spotify',
    nombreOficial: 'Spotify',
    categoriaId: 'streaming',
    keywords: ['spotify'],
  ),
  _MarcaCanonica(
    slug: 'amazon',
    nombreOficial: 'Amazon Prime & Gift',
    categoriaId: 'streaming',
    keywords: ['amazon'],
  ),
  _MarcaCanonica(
    slug: 'google_play',
    nombreOficial: 'Google Play',
    categoriaId: 'streaming',
    keywords: ['google_play', 'googleplay'],
  ),
  _MarcaCanonica(
    slug: 'starbucks',
    nombreOficial: 'Starbucks Card',
    categoriaId: 'streaming',
    keywords: ['starbucks'],
  ),

  // Videojuegos
  _MarcaCanonica(
    slug: 'xbox',
    nombreOficial: 'Xbox Game Pass / Live',
    categoriaId: 'videojuegos',
    keywords: ['xbox'],
  ),
  _MarcaCanonica(
    slug: 'playstation',
    nombreOficial: 'PlayStation Plus / PSN',
    categoriaId: 'videojuegos',
    keywords: ['playstation', 'psn', 'play_station'],
  ),
  _MarcaCanonica(
    slug: 'nintendo',
    nombreOficial: 'Nintendo eShop',
    categoriaId: 'videojuegos',
    keywords: ['nintendo'],
  ),
  _MarcaCanonica(
    slug: 'roblox',
    nombreOficial: 'Roblox Robux & Cards',
    categoriaId: 'videojuegos',
    keywords: ['roblox'],
  ),
  _MarcaCanonica(
    slug: 'free_fire',
    nombreOficial: 'Free Fire Diamantes',
    categoriaId: 'videojuegos',
    keywords: ['free_fire', 'freefire', 'garena'],
  ),
];

/// Representa a una empresa proveedora única y consolidada con todos sus productos.
class CompaniaServicio {
  const CompaniaServicio({
    required this.idServicio,
    required this.nombre,
    required this.slug,
    required this.productos,
    this.categoriaId,
    this.idCatTipoServicio,
  });

  final int idServicio;
  final String nombre;
  final String slug;
  final List<CatalogoProducto> productos;
  final String? categoriaId;
  final int? idCatTipoServicio;

  CatalogoProducto get productoPrincipal => productos.first;

  /// Clasifica los productos de esta compañía en subcategorías semánticas
  /// (ej: "Tiempo Aire", "Paquetes de Datos", "Planes / Factura").
  Map<String, List<CatalogoProducto>> get subgrupos {
    if (productos.length <= 3) {
      return {'Todos': productos};
    }

    final mapa = <String, List<CatalogoProducto>>{};

    for (final prod in productos) {
      final text = '${prod.servicio} ${prod.producto} ${prod.legend ?? ''}'.toLowerCase();

      String grupo;
      if (text.contains('paquete') ||
          text.contains('sin limite') ||
          text.contains('datos') ||
          text.contains('internet') ||
          text.contains('gigas') ||
          text.contains('mb') ||
          text.contains('gb') ||
          text.contains('ilimitado') ||
          text.contains('noches') ||
          text.contains('social')) {
        grupo = 'Paquetes e Internet';
      } else if (text.contains('plan') ||
          text.contains('pospago') ||
          text.contains('factura') ||
          text.contains('recibo') ||
          text.contains('mensualidad') ||
          !prod.esPrecioFinal) {
        grupo = 'Planes y Facturas';
      } else if (text.contains('membresia') ||
          text.contains('pass') ||
          text.contains('plus') ||
          text.contains('suscripcion')) {
        grupo = 'Membresías y Pases';
      } else if (text.contains('tarjeta') ||
          text.contains('pin') ||
          text.contains('gift') ||
          text.contains('codigo') ||
          text.contains('robux') ||
          text.contains('diamante')) {
        grupo = 'Tarjetas y Pines';
      } else {
        grupo = 'Recargas y Saldo';
      }

      mapa.putIfAbsent(grupo, () => []).add(prod);
    }

    // Si solo hubo un grupo, retornar 'Todos'
    if (mapa.length <= 1) {
      return {'Todos': productos};
    }

    // Si hay varios grupos, incluir 'Todos' al principio
    final resultado = <String, List<CatalogoProducto>>{
      'Todos': productos,
      ...mapa,
    };

    return resultado;
  }
}

/// Agrupa todos los productos del catálogo por marca canónica consolidada.
List<CompaniaServicio> agruparPorCompania(List<CatalogoProducto> productos) {
  if (productos.isEmpty) return const [];

  // Mapa de marca canónica slug -> lista de productos
  final marcasAgrupadas = <String, (String, String?, int, int?, List<CatalogoProducto>)>{};
  final serviciosGenericos = <int, (String, String, int?, List<CatalogoProducto>)>{};

  for (final p in productos) {
    final slugServicio = slugTexto(p.servicio).replaceAll('_', '');
    final slugProducto = slugTexto(p.producto).replaceAll('_', '');
    final textoBusqueda = '$slugServicio $slugProducto';

    _MarcaCanonica? matchMarca;
    for (final marca in _marcasCanonicas) {
      for (final kw in marca.keywords) {
        final kwNorm = kw.replaceAll('_', '');
        if (slugServicio.contains(kwNorm) || textoBusqueda.contains(kwNorm)) {
          matchMarca = marca;
          break;
        }
      }
      if (matchMarca != null) break;
    }

    if (matchMarca != null) {
      if (marcasAgrupadas.containsKey(matchMarca.slug)) {
        marcasAgrupadas[matchMarca.slug]!.$5.add(p);
      } else {
        marcasAgrupadas[matchMarca.slug] = (
          matchMarca.nombreOficial,
          matchMarca.categoriaId,
          p.idServicio,
          p.idCatTipoServicio,
          [p],
        );
      }
    } else {
      // Servicio genérico (ej. agua local, impuesto) agrupado por su idServicio
      if (serviciosGenericos.containsKey(p.idServicio)) {
        serviciosGenericos[p.idServicio]!.$4.add(p);
      } else {
        serviciosGenericos[p.idServicio] = (
          p.servicio,
          slugTexto(p.servicio),
          p.idCatTipoServicio,
          [p],
        );
      }
    }
  }

  final resultado = <CompaniaServicio>[];

  // 1. Añadir marcas canónicas
  for (final entry in marcasAgrupadas.entries) {
    final prods = entry.value.$5..sort((a, b) {
      final pa = double.tryParse(a.precio) ?? 0.0;
      final pb = double.tryParse(b.precio) ?? 0.0;
      return pa.compareTo(pb);
    });

    resultado.add(
      CompaniaServicio(
        idServicio: entry.value.$3,
        nombre: entry.value.$1,
        slug: entry.key,
        categoriaId: entry.value.$2,
        idCatTipoServicio: entry.value.$4,
        productos: prods,
      ),
    );
  }

  // 2. Añadir servicios genéricos
  for (final entry in serviciosGenericos.entries) {
    final prods = entry.value.$4..sort((a, b) {
      final pa = double.tryParse(a.precio) ?? 0.0;
      final pb = double.tryParse(b.precio) ?? 0.0;
      return pa.compareTo(pb);
    });

    resultado.add(
      CompaniaServicio(
        idServicio: entry.key,
        nombre: entry.value.$1,
        slug: entry.value.$2,
        idCatTipoServicio: entry.value.$3,
        productos: prods,
      ),
    );
  }

  return resultado;
}

/// Obtiene todas las compañías que pertenecen a una categoría específica sin duplicados.
List<CompaniaServicio> obtenerCompaniasPorCategoria(
  List<CatalogoProducto> catalogo,
  CategoriaServicio categoria,
) {
  final todas = agruparPorCompania(catalogo);
  final resultado = <CompaniaServicio>[];

  for (final comp in todas) {
    var pertenece = false;

    if (comp.categoriaId != null && comp.categoriaId == categoria.id) {
      pertenece = true;
    } else {
      final slug = slugTexto('${comp.slug} ${comp.nombre}').replaceAll('_', '');
      for (final marca in categoria.marcas) {
        if (slug.contains(marca.replaceAll('_', ''))) {
          pertenece = true;
          break;
        }
      }
    }

    if (pertenece) {
      resultado.add(comp);
    }
  }

  // Ordenar compañías alfabéticamente o por importancia
  resultado.sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
  return resultado;
}

/// Busca una compañía específica por nombre o slug de marca en el catálogo.
CompaniaServicio? obtenerCompaniaPorNombre(
  List<CatalogoProducto> catalogo,
  String nombreServicio,
) {
  final todas = agruparPorCompania(catalogo);
  final target = slugTexto(nombreServicio).replaceAll('_', '');

  for (final comp in todas) {
    final slug = slugTexto('${comp.slug} ${comp.nombre}').replaceAll('_', '');
    if (slug.contains(target) || target.contains(slug)) {
      return comp;
    }
  }

  return null;
}
