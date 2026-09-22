import 'package:flutter/material.dart';

import '../../../core/utils/texto.dart';
import 'catalogo_producto.dart';

/// Modelo de categoría de servicio para agrupación en la interfaz.
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
      marcas: ['telcel', 'att', 'movistar', 'unefon', 'bait', 'virgin', 'pillofon', 'recarga'],
    ),
    CategoriaServicio(
      id: 'luz_agua',
      titulo: 'Luz, Agua y Gas',
      icono: Icons.bolt_rounded,
      color: Color(0xFF008954),
      marcas: ['cfe', 'siapa', 'sacmex', 'agua', 'naturgy', 'gas', 'luz', 'cfe_suministrador'],
    ),
    CategoriaServicio(
      id: 'internet_tv',
      titulo: 'Internet y Televisión',
      icono: Icons.wifi_rounded,
      color: Color(0xFF7C3AED),
      marcas: ['totalplay', 'izzi', 'megacable', 'sky', 'dish', 'telmex', 'cable', 'axtel'],
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
      marcas: ['netflix', 'spotify', 'amazon', 'google_play', 'starbucks', 'apple', 'blim'],
    ),
    CategoriaServicio(
      id: 'videojuegos',
      titulo: 'Videojuegos y Pines',
      icono: Icons.sports_esports_rounded,
      color: Color(0xFFEA580C),
      marcas: ['xbox', 'playstation', 'nintendo', 'roblox', 'free_fire', 'steam', 'blizzard'],
    ),
  ];
}

/// Representa a una compañía / empresa proveedora con todos sus productos disponibles.
class CompaniaServicio {
  const CompaniaServicio({
    required this.idServicio,
    required this.nombre,
    required this.productos,
    this.idCatTipoServicio,
  });

  final int idServicio;
  final String nombre;
  final List<CatalogoProducto> productos;
  final int? idCatTipoServicio;

  /// Retorna el producto con menor precio o el más representativo
  CatalogoProducto get productoPrincipal => productos.first;
}

/// Agrupa todos los productos del catálogo por compañía (idServicio / servicio).
List<CompaniaServicio> agruparPorCompania(List<CatalogoProducto> productos) {
  if (productos.isEmpty) return const [];

  final map = <int, (String, int?, List<CatalogoProducto>)>{};

  for (final p in productos) {
    if (map.containsKey(p.idServicio)) {
      map[p.idServicio]!.$3.add(p);
    } else {
      map[p.idServicio] = (p.servicio, p.idCatTipoServicio, [p]);
    }
  }

  return map.entries.map((entry) {
    // Ordenar los productos de la compañía por precio ascendente
    final prods = entry.value.$3..sort((a, b) {
      final pa = double.tryParse(a.precio) ?? 0.0;
      final pb = double.tryParse(b.precio) ?? 0.0;
      return pa.compareTo(pb);
    });

    return CompaniaServicio(
      idServicio: entry.key,
      nombre: entry.value.$1,
      idCatTipoServicio: entry.value.$2,
      productos: prods,
    );
  }).toList();
}

/// Obtiene todas las compañías que pertenecen a una categoría específica.
List<CompaniaServicio> obtenerCompaniasPorCategoria(
  List<CatalogoProducto> catalogo,
  CategoriaServicio categoria,
) {
  final todas = agruparPorCompania(catalogo);
  final resultado = <CompaniaServicio>[];

  for (final comp in todas) {
    final slug = slugTexto(comp.nombre).replaceAll('_', '');
    var coincide = false;

    for (final marca in categoria.marcas) {
      if (slug.contains(marca.replaceAll('_', ''))) {
        coincide = true;
        break;
      }
    }

    if (coincide) {
      resultado.add(comp);
    }
  }

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
    final slug = slugTexto(comp.nombre).replaceAll('_', '');
    if (slug.contains(target) || target.contains(slug)) {
      return comp;
    }
  }

  return null;
}
