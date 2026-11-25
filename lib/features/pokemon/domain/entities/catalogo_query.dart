/// Criterios para buscar, filtrar y ordenar el catálogo (RF-FIL-01, RF-FIL-03).
class CatalogoQuery {
  const CatalogoQuery({
    this.nombre = '',
    this.tipoIds = const <int>{},
    this.generacionIds = const <int>{},
    this.orden = CatalogoOrden.numero,
  });

  /// Texto de búsqueda.
  final String nombre;

  /// Tipos pedidos. El Pokémon debe tener al menos uno. Vacío = sin filtro.
  final Set<int> tipoIds;

  /// Generaciones pedidas. Vacío = sin filtro.
  final Set<int> generacionIds;

  final CatalogoOrden orden;
}

/// Criterio de orden del catálogo
enum CatalogoOrden {numero, nombre, totalBase}