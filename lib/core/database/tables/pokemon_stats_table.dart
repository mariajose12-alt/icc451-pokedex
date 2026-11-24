import 'package:drift/drift.dart';

import 'pokemon_table.dart';

// Estadísticas base de un Pokémon: una fila por cada stat (6 por Pokémon).
// Sirven para las barras del detalle (RF-DET-02) y para ordenar por total
// base (RF-FIL-03).
@DataClassName('PokemonStatEntry')
class PokemonStats extends Table {
  // Si se borra el Pokémon, se borran sus stats (en cascada).
  IntColumn get pokemonId =>
      integer().references(Pokemons, #id, onDelete: KeyAction.cascade)();

  // Id del stat tal como lo da PokeAPI:
  // 1 hp, 2 attack, 3 defense, 4 special-attack, 5 special-defense, 6 speed.
  // No hay tabla de nombres: la interfaz pone los rótulos con i18n.
  IntColumn get statId => integer()();

  IntColumn get baseStat => integer()();

  // Un Pokémon no puede tener dos veces el mismo stat (PS-06).
  @override
  Set<Column> get primaryKey => {pokemonId, statId};
}
