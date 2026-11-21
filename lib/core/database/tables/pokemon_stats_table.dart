import 'package:drift/drift.dart';

import 'package:pokedex/core/database/tables/pokemon_table.dart';

/// Estadisticas base de un pokemon. Una fila por pokemon
/// Se usa para ordenar por un total base (RF-FIL-03) y para el detalle (RF-DET-02)
@DataClassName('PokemonStatEntry')
class PokemonStats extends Table {
  /// Pokemon al que pertenecen. Es la clave primaria, no pueden haber dos filas
  /// de estadisticas para el mismo pokemon.
  IntColumn get pokemonId => integer().references((Pokemons), #id)();

  IntColumn get hp => integer()();
  IntColumn get attack => integer()();
  IntColumn get defense => integer()();
  IntColumn get specialAttack => integer()();
  IntColumn get specialDefense => integer()();
  IntColumn get speed => integer()();

  @override
  Set<Column> get primaryKey => {pokemonId};
}
