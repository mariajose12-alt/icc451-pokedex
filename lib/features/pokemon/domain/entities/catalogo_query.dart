import 'package:equatable/equatable.dart';

/// Criterios para buscar, filtrar y ordenar el catálogo (RF-FIL-01, RF-FIL-03).
/// Dart puro: no depende de Drift ni de Flutter.
class CatalogoQuery extends Equatable {
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

  /// true si hay algún filtro de contenido. El orden no cuenta como filtro.
  bool get hasActiveFilters =>
      nombre.isNotEmpty || tipoIds.isNotEmpty || generacionIds.isNotEmpty;

  CatalogoQuery copyWith({
    String? nombre,
    Set<int>? tipoIds,
    Set<int>? generacionIds,
    CatalogoOrden? orden,
  }) {
    return CatalogoQuery(
      nombre: nombre ?? this.nombre,
      tipoIds: tipoIds ?? this.tipoIds,
      generacionIds: generacionIds ?? this.generacionIds,
      orden: orden ?? this.orden,
    );
  }

  @override
  List<Object?> get props => [nombre, tipoIds, generacionIds, orden];
}

/// Criterio de orden del catálogo.
enum CatalogoOrden { numero, nombre, totalBase }
