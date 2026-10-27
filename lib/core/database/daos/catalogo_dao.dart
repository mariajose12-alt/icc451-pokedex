import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/poke_types_table.dart';
import '../tables/pokemon_table.dart';
import '../tables/pokemon_types_table.dart';
import '../tables/sync_metadata_table.dart';

part 'catalogo_dao.g.dart';

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
    return (select(syncMetadata)
      ..where((s) => s.resourceKey.equals(resourceKey)))
        .watchSingleOrNull();
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
      await (delete(this.pokemonTypes)
        ..where((t) => t.pokemonId.isIn(ids)))
          .go();
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