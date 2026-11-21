import 'package:equatable/equatable.dart';

/// Una forma de la especie, incluida la normal (RF-DET-08, RF-DET-09).
class PokemonForm extends Equatable {
  const PokemonForm({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.typeIds,
    required this.spriteUrl,
    required this.shinySpriteUrl,
    required this.artworkUrl,
    required this.shinyArtworkUrl,
  });

  /// Id del Pokémon-forma en PokeAPI (Rattata de Alola = 10091).
  final int id;
  final String name;
  final bool isDefault;

  /// Ids de sus tipos, en orden de slot. Los nombres los da la tabla de tipos.
  final List<int> typeIds;
  final String? spriteUrl;
  final String? shinySpriteUrl;
  final String? artworkUrl;
  final String? shinyArtworkUrl;

  /// ¿Existe alguna imagen shiny? Si no, el botón shiny no tiene qué mostrar.
  bool get hasShiny => shinyArtworkUrl != null || shinySpriteUrl != null;

  @override
  List<Object?> get props => [
    id,
    name,
    isDefault,
    typeIds,
    spriteUrl,
    shinySpriteUrl,
    artworkUrl,
    shinyArtworkUrl,
  ];
}
