import 'package:drift/drift.dart';

import 'connection.dart';
import 'tables/pokemon_stats_table.dart';
import 'tables/type_efficacies_table.dart';
import 'tables/abilities_table.dart';
import 'tables/poke_types_table.dart';
import 'tables/pokemon_abilities_table.dart';
import 'tables/pokemon_table.dart';
import 'tables/pokemon_types_table.dart';
import 'tables/favorites_table.dart';
import 'tables/trivia_results_table.dart';
import 'tables/trivia_answers_table.dart';
import 'tables/sync_metadata_table.dart';
import 'tables/evolution_nodes_table.dart';
import 'tables/moves_table.dart';
import 'tables/pokemon_egg_groups_table.dart';
import 'tables/pokemon_form_types_table.dart';
import 'tables/pokemon_forms_table.dart';
import 'tables/pokemon_moves_table.dart';
import 'tables/version_groups_table.dart';
import 'daos/favorites_dao.dart';
import 'daos/catalogo_dao.dart';
import 'daos/detalle_dao.dart';
part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Pokemons,
    PokeTypes,
    Abilities,
    PokemonTypes,
    PokemonAbilities,
    PokemonStats,
    TypeEfficacies,
    Moves,
    VersionGroups,
    PokemonMoves,
    PokemonEggGroups,
    EvolutionNodes,
    PokemonForms,
    PokemonFormTypes,
    Favorites,
    TriviaResults,
    TriviaAnswers,
    SyncMetadata,
  ],
  daos: [CatalogoDao, DetalleDao, FavoritesDao],
)
class AppDatabase extends _$AppDatabase {
  // Constructor principal
  AppDatabase(super.executor);

  // Constructor para la app real, abre el archivo del telefono
  AppDatabase.archivo() : super(openConnection());

  // Versión del esquema. Cada vez que cambian las tablas, se sube en 1 y se
  //  1: esquema inicial.
  //  2: stats base y efectividades entre tipos (detalle del Pokémon).
  //  3: datos del detalle bajo demanda: habilidades con nombre es/en,
  //     movimientos, egg groups, evoluciones y formas.
  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    // Base nueva: crea todas las tablas.
    onCreate: (m) => m.createAll(),

    // Base que ya existía en una versión anterior: solo se añade lo nuevo.
    // No se borra nada, así que favoritos y catálogo se conservan.
    onUpgrade: (m, from, to) async {
      if (from < 3) {
        // Solo se crean tablas y se agregan dos columnas nulas. No hace falta
        // forzar una nueva sincronización: estos datos se descargan al abrir
        // cada Pokémon, y los favoritos y el catálogo no se tocan.
        await m.addColumn(abilities, abilities.nameEs);
        await m.addColumn(abilities, abilities.nameEn);
        await m.createTable(moves);
        await m.createTable(versionGroups);
        await m.createTable(pokemonMoves);
        await m.createTable(pokemonEggGroups);
        await m.createTable(evolutionNodes);
        await m.createTable(pokemonForms);
        await m.createTable(pokemonFormTypes);
      }
    },

    // Se ejecuta cada vez que se abre la base de datos.
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
