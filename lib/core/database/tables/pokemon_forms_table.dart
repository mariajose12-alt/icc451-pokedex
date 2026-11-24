import 'package:drift/drift.dart';

// Formas de cada especie, incluida la normal (RF-DET-08, RF-DET-09).
// Una forma es un "Pokémon" más en PokeAPI, con su propio id (Rattata de
// Alola = 10091) y los mismos números de Pokédex que su base, por eso no
// caben en la tabla pokemons (que tiene el número nacional único).
//
// Incluir la forma normal aquí permite que el shiny funcione igual para
// todos los Pokémon, tengan o no formas.
@DataClassName('PokemonFormEntry')
class PokemonForms extends Table {
  // Id del Pokémon-forma en PokeAPI.
  IntColumn get id => integer()();

  // Id de la especie (el Pokémon base al que pertenece).
  IntColumn get speciesId => integer()();

  TextColumn get name => text()();

  BoolColumn get isDefault => boolean()();

  // Direcciones de las imágenes; nulas cuando PokeAPI no las tiene.
  TextColumn get spriteUrl => text().nullable()();
  TextColumn get shinySpriteUrl => text().nullable()();
  TextColumn get artworkUrl => text().nullable()();
  TextColumn get shinyArtworkUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
