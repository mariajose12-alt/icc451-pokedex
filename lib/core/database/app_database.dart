import 'package:drift/drift.dart';

import 'connection.dart';
import 'tables/abilities_table.dart';
import 'tables/poke_types_table.dart';
import 'tables/pokemon_abilities_table.dart';
import 'tables/pokemon_table.dart';
import 'tables/pokemon_types_table.dart';
import 'tables/favorites_table.dart';
import 'tables/trivia_results_table.dart';
import 'tables/trivia_answers_table.dart';
import 'tables/sync_metadata_table.dart';
import 'daos/catalogo_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Pokemons,
    PokeTypes,
    Abilities,
    PokemonTypes,
    PokemonAbilities,
    Favorites,
    TriviaResults,
    TriviaAnswers,
    SyncMetadata,
  ],
  daos: [CatalogoDao],
)
class AppDatabase extends _$AppDatabase {

  // Constructor principal
  AppDatabase(super.executor);

  // Constructor para la app real, abre el archivo del telefono
  AppDatabase.archivo() : super(openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    // Crea todas las tablas la primera vez.
    onCreate: (m) => m.createAll(),
    // Se ejecuta cada vez que se abre la base de datos.
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

}