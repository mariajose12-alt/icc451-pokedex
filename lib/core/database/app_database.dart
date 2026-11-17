import 'package:drift/drift.dart';
import 'package:pokedex/core/sync/sync_status.dart';

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
import 'daos/catalogo_dao.dart';

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

  // Versión del esquema. Cada vez que cambian las tablas, se sube en 1 y se
  // describe cómo migrar en onUpgrade.
  //  1: esquema inicial.
  //  2: stats base y efectividades entre tipos (detalle del Pokémon).
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    // Base nueva: crea todas las tablas.
    onCreate: (m) => m.createAll(),

    // Base que ya existía en una versión anterior: solo se añade lo nuevo.
    // No se borra nada, así que favoritos y catálogo se conservan.
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(pokemonStats);
        await m.createTable(typeEfficacies);

        // Los Pokémon ya guardados no tienen stats. Se deja el catálogo
        // marcado como "a medias desde el principio" para que la próxima
        // sincronización lo descargue de nuevo (el upsert actualiza lo
        // existente sin duplicar).
        // Se usa 'syncing' con cursor 0, NO 'failed': con 'failed' el
        // sincronizador retomaría desde el cursor viejo (1025) y daría el
        // catálogo por completo sin tener los stats.
        // lastSuccessfulAt no se toca: el indicador sigue mostrando la fecha.
        await (update(
          syncMetadata,
        )..where((s) => s.resourceKey.equals(SyncResources.catalog))).write(
          const SyncMetadataCompanion(
            status: Value(SyncStatus.syncing),
            cursorOrOffset: Value('0'),
          ),
        );
      }
    },

    // Se ejecuta cada vez que se abre la base de datos.
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
