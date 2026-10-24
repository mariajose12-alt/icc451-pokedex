import 'package:equatable/equatable.dart';

import 'pokemon_type.dart';

/// Pokémon del catálogo. Entidad del dominio: no depende de Flutter,
/// de GraphQL ni de Drift.
class Pokemon extends Equatable {
  const Pokemon({
    required this.id,
    required this.name,
    required this.nationalDexNumber,
    required this.generationId,
    required this.height,
    required this.weight,
    required this.types,
    this.artworkUrl,
    this.spriteUrl,
  });

  final int id;
  final String name;
  final int nationalDexNumber;
  final int generationId;

  /// Altura en decímetros y peso en hectogramos (unidades de PokeAPI).
  final int height;
  final int weight;

  /// Imagen oficial y sprite de respaldo (RF-DET-01). Pueden faltar.
  final String? artworkUrl;
  final String? spriteUrl;

  /// Tipos ordenados por slot: el primero es el tipo principal.
  final List<PokemonType> types;

  @override
  List<Object?> get props => [
    id,
    name,
    nationalDexNumber,
    generationId,
    height,
    weight,
    artworkUrl,
    spriteUrl,
    types,
  ];
}
