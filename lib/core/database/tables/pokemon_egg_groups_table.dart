import 'package:drift/drift.dart';

import 'pokemon_table.dart';

// Egg groups de cada Pokémon (RF-DET-07). Un Pokémon tiene uno o dos.
@DataClassName('PokemonEggGroupEntry')
class PokemonEggGroups extends Table {
  IntColumn get pokemonId =>
      integer().references(Pokemons, #id, onDelete: KeyAction.cascade)();

  // Identificador de PokeAPI: 'monster', 'plant', 'water1'...
  TextColumn get eggGroup => text()();

  @override
  Set<Column> get primaryKey => {pokemonId, eggGroup};
}
