import 'dart:ui' show Color;

import 'package:equatable/equatable.dart';

/// Una estadística de la carta: «HP», 45.
class PokemonCardStat extends Equatable {
  const PokemonCardStat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  List<Object?> get props => [label, value];
}

/// Todo lo que muestra la Pokémon Card, ya formateado. La carta no consulta
/// la base ni conoce las entidades: quien la abre arma este objeto.
class PokemonCardData extends Equatable {
  const PokemonCardData({
    required this.name,
    required this.nationalDexNumber,
    required this.typeNames,
    required this.accentColor,
    required this.stats,
    required this.total,
    required this.heightWeight,
    required this.abilities,
    required this.weakTo,
    required this.resists,
    this.imageUrl,
  });

  final String name;
  final int nationalDexNumber;

  /// Identificadores de PokeAPI: 'grass', 'poison'.
  final List<String> typeNames;

  /// Color del tipo principal: de él salen los colores de la carta.
  final Color accentColor;

  /// Las seis en este orden: HP, ATK, DEF, SPA, SPD, SPE.
  final List<PokemonCardStat> stats;
  final int total;

  /// Ya con unidades: «0,7 m · 6,9 kg».
  final String heightWeight;
  final String abilities;
  final String weakTo;
  final String resists;
  final String? imageUrl;

  @override
  List<Object?> get props => [
    name,
    nationalDexNumber,
    typeNames,
    accentColor,
    stats,
    total,
    heightWeight,
    abilities,
    weakTo,
    resists,
    imageUrl,
  ];
}
