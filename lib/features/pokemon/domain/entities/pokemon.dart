import 'package:equatable/equatable.dart';

import 'pokemon_type.dart';
import 'pokemon_stat.dart';

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
    this.stats = const <PokemonStat>[],
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

  /// Stats base ordenados por statId (hp, ataque, defensa, ataque especial,
  /// defensa especial, velocidad). Solo los trae el detalle: la lista del
  /// catálogo no los carga y aquí viene vacío.
  final List<PokemonStat> stats;

  /// Suma de los stats base (el "total" de RF-DET-02). 0 si no hay stats.
  int get totalStats {
    var total = 0;
    for (final stat in stats) {
      total += stat.baseStat;
    }
    return total;
  }

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
    stats,
  ];
}
