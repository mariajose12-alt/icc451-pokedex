import 'package:drift/drift.dart';

import 'poke_types_table.dart';
import 'pokemon_table.dart';


@DataClassName('PokemonTypeEntry')
class PokemonTypes extends Table {
  // Si se borra un pokemon, se borran sus tipos, osea en cascada
  IntColumn get pokemonId =>
      integer().references(Pokemons, #id, onDelete: KeyAction.cascade)();
  IntColumn get typeId => integer().references(PokeTypes, #id, onDelete: KeyAction.cascade)();

  IntColumn get slot => integer()();

  @override
  Set<Column> get primaryKey => {pokemonId, slot};

}