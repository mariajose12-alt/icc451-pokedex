import 'package:drift/drift.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/core/database/tables/poke_types_table.dart';
import 'package:pokedex/core/database/tables/pokemon_table.dart';
import 'package:pokedex/core/database/tables/pokemon_types_table.dart';
import 'package:pokedex/core/database/tables/sync_metadata_table.dart';

part 'catalogo_dao.g.dart';

// Un Pokémon junto con sus tipos, ya ordenados por slot
// (el 1 es el principal). Es lo que necesita la lista del catálogo:
// así no hace falta una consulta por tarjeta para pedir los tipos.
class PokemonWithTypes {
  PokemonWithTypes({required this.pokemon, required this.types});

  final PokemonEntry pokemon;
  final List<TypeEntry> types;
}

// DAO del catálogo: lecturas reactivas para la UI y escrituras por página
// para la sincronización (ADR-0003).
@DriftAccessor(tables: [Pokemons, PokeTypes, PokemonTypes, SyncMetadata])
class CatalogoDao extends DatabaseAccessor<AppDatabase>
    with _$CatalogoDaoMixin {
  CatalogoDao(super.db);

  // Emite la lista completa cada vez que cambia la tabla (OF-16).
  Stream<List<PokemonEntry>> watchPokemons() {
    return (select(pokemons)..orderBy([(p) => OrderingTerm.asc(p.id)])).watch();
  }

  // Catálogo completo con los tipos de cada Pokémon, en UNA consulta.
  // Pasos:
  //  1. Une pokemons con pokemon_types y con poke_types (LEFT JOIN: un
  //     Pokémon sin tipos guardados no desaparece de la lista).
  //  2. Ordena por id y, dentro de cada Pokémon, por slot.
  //  3. La consulta devuelve una fila por cada (Pokémon, tipo); aquí se
  //     agrupan para obtener un elemento por Pokémon.
  // Drift vuelve a emitir cuando cambia cualquiera de las tres tablas.
  Stream<List<PokemonWithTypes>> watchCatalogWithTypes() {
    final query =
        select(pokemons).join([
          leftOuterJoin(
            pokemonTypes,
            pokemonTypes.pokemonId.equalsExp(pokemons.id),
          ),
          leftOuterJoin(pokeTypes, pokeTypes.id.equalsExp(pokemonTypes.typeId)),
        ])..orderBy([
          OrderingTerm.asc(pokemons.id),
          OrderingTerm.asc(pokemonTypes.slot),
        ]);

    return query.watch().map((rows) {
      // El mapa conserva el orden de inserción, que ya es el orden por id.
      final byId = <int, PokemonWithTypes>{};
      for (final row in rows) {
        final pokemon = row.readTable(pokemons);
        final type = row.readTableOrNull(pokeTypes);
        final item = byId.putIfAbsent(
          pokemon.id,
          () => PokemonWithTypes(pokemon: pokemon, types: <TypeEntry>[]),
        );
        if (type != null) {
          item.types.add(type);
        }
      }
      return byId.values.toList();
    });
  }

  // Número de Pokémon guardados. Sirve para el umbral offline (RF-TRV-05).
  Stream<int> watchCount() {
    final conteo = pokemons.id.count();
    final consulta = selectOnly(pokemons)..addColumns([conteo]);
    return consulta.map((fila) => fila.read(conteo) ?? 0).watchSingle();
  }

  // Tipos de un Pokémon, en orden de slot (el 1 es el principal).
  Stream<List<PokemonTypeEntry>> watchTypesOf(int pokemonId) {
    return (select(pokemonTypes)
          ..where((t) => t.pokemonId.equals(pokemonId))
          ..orderBy([(t) => OrderingTerm.asc(t.slot)]))
        .watch();
  }

  // Estado de sincronización de un recurso. Lo lee el indicador (IND-04).
  Stream<SyncMetadataEntry?> watchSyncState(String resourceKey) {
    return (select(
      syncMetadata,
    )..where((s) => s.resourceKey.equals(resourceKey))).watchSingleOrNull();
  }

  // Lectura única del estado. El sincronizador la usa para saber
  // desde dónde reanudar. getSingleOrNull devuelve null si no hay fila.
  Future<SyncMetadataEntry?> readSyncState(String resourceKey) {
    return (select(
      syncMetadata,
    )..where((s) => s.resourceKey.equals(resourceKey))).getSingleOrNull();
  }

  // Guarda solo el estado (por ejemplo, "failed") sin tocar el
  // catálogo. Solo se actualizan las columnas que vengan con valor: lo que
  // se deje como Value.absent() (cursor, fecha) se conserva.
  Future<void> saveSyncState(SyncMetadataCompanion state) {
    return into(syncMetadata).insertOnConflictUpdate(state);
  }

  // Guarda una página completa en una sola transacción (PS-07, PA-09).
  // Si la app se cierra a mitad, no queda nada a medias.
  Future<void> savePage({
    required List<PokeTypesCompanion> types,
    required List<PokemonsCompanion> pokemons,
    required List<PokemonTypesCompanion> pokemonTypes,
    required SyncMetadataCompanion syncState,
  }) {
    return transaction(() async {
      await batch((b) {
        // Primero los tipos: las relaciones los referencian (clave foránea).
        b.insertAllOnConflictUpdate(pokeTypes, types);
        // Upsert, nunca insertOrReplace: borrar una fila dispararía las
        // cascadas hacia tipos y habilidades (ADR-0003).
        b.insertAllOnConflictUpdate(this.pokemons, pokemons);
      });

      // Reemplaza los tipos de los Pokémon de esta página. Solo borra filas
      // de la tabla de relación, nunca de pokemons.
      final ids = pokemons.map((p) => p.id.value).toList();
      await (delete(
        this.pokemonTypes,
      )..where((t) => t.pokemonId.isIn(ids))).go();
      await batch((b) => b.insertAll(this.pokemonTypes, pokemonTypes));

      // Cursor y estado de la página, en la misma transacción.
      await into(syncMetadata).insertOnConflictUpdate(syncState);
    });
  }

  // Guarda la ruta local de la imagen de un Pokémon después de descargarla (T-009).
  Future<int> saveArtworkLocalPath(int pokemonId, String ruta) {
    return (update(pokemons)..where((p) => p.id.equals(pokemonId))).write(
      PokemonsCompanion(artworkLocalPath: Value(ruta)),
    );
  }
}
