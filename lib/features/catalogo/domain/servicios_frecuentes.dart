import '../../../core/utils/texto.dart';
import 'catalogo_producto.dart';

/// Marcas que el usuario reconoce de inmediato, en orden de prioridad para la
/// sección "Los más usados" del inicio.
const List<String> _marcasFrecuentes = [
  'telcel',
  'att',
  'movistar',
  'netflix',
  'spotify',
  'google_play',
  'amazon',
  'playstation',
  'xbox',
  'nintendo',
  'starbucks',
  'totalplay',
  'dish',
];

/// Recorta el catálogo a un producto representativo por marca frecuente
/// (elige el de menor precio disponible de cada marca, conservando el orden
/// de interés de [_marcasFrecuentes]).
List<CatalogoProducto> productosFrecuentes(List<CatalogoProducto> catalogo) {
  if (catalogo.isEmpty) {
    return const [];
  }
  final mejores = <String, CatalogoProducto>{};
  for (final p in catalogo) {
    final s = slugTexto(p.servicio).replaceAll('_', '');
    if (s.isEmpty) {
      continue;
    }
    for (final marca in _marcasFrecuentes) {
      if (s.contains(marca.replaceAll('_', '')) && _esMejor(p, mejores[marca])) {
        mejores[marca] = p;
      }
    }
  }
  final resultado = <CatalogoProducto>[];
  for (final marca in _marcasFrecuentes) {
    final p = mejores[marca];
    if (p != null) {
      resultado.add(p);
    }
  }
  return resultado.take(8).toList();
}

bool _esMejor(CatalogoProducto candidato, CatalogoProducto? actual) {
  if (actual == null) {
    return true;
  }
  final precioCandidato = _precio(candidato);
  final precioActual = _precio(actual);
  if (precioCandidato > 0 && precioActual == 0) {
    return true;
  }
  if (precioCandidato == 0 && precioActual > 0) {
    return false;
  }
  return precioCandidato < precioActual;
}

double _precio(CatalogoProducto p) => double.tryParse(p.precio) ?? 0.0;