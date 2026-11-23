import 'package:drift/drift.dart';

import 'moves_table.dart';
import 'version_groups_table.dart';

// Movimientos que aprende cada Pokémon: una fila por Pokémon, grupo de
// versión, método de aprendizaje y movimiento (RF-DET-05; D6 POKEMON_MOVE).
//
// pokemonId NO tiene clave foránea hacia pokemons a propósito: también guarda
// los movimientos de las formas (Rattata de Alola = 10091), que no están en
// esa tabla.
@DataClassName('PokemonMoveEntry')
class PokemonMoves extends Table {
  IntColumn get pokemonId => integer()();

  IntColumn get versionGroupId => integer().references(VersionGroups, #id)();

  // Id del método en PokeAPI: 1 level-up, 2 egg, 3 tutor, 4 machine (TM).
  // Solo se guardan esos cuatro, que son los que pide RF-DET-05.
  IntColumn get learnMethodId => integer()();

  IntColumn get moveId => integer().references(Moves, #id)();

  // Nivel en que se aprende. Es 0 cuando el método no usa nivel.
  IntColumn get level => integer().withDefault(const Constant(0))();

  // Un mismo movimiento puede aprenderse en dos niveles distintos del mismo
  // grupo, por eso el nivel forma parte de la clave (PS-06).
  //
  // El orden importa: la pestaña Movs. busca por Pokémon y grupo de versión,
  // y SQLite usa estas dos primeras columnas como índice (RNF-REN-02).
  @override
  Set<Column> get primaryKey => {
    pokemonId,
    versionGroupId,
    learnMethodId,
    moveId,
    level,
  };
}
