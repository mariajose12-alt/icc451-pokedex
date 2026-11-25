import 'package:drift/drift.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/core/database/tables/poke_types_table.dart';
import 'package:pokedex/core/database/tables/pokemon_table.dart';
import 'package:pokedex/core/database/tables/pokemon_types_table.dart';
import 'package:pokedex/core/database/tables/sync_metadata_table.dart';
import 'package:pokedex/core/database/tables/pokemon_stats_table.dart';
import 'package:pokedex/core/database/tables/type_efficacies_table.dart';

import 'package:pokedex/features/pokemon/domain/entities/catalogo_query.dart';

part 'catalogo_dao.g.dart';

// Un Pokémon junto con sus tipos, ya ordenados por slot
// (el 1 es el principal). Es lo que necesita la lista del catálogo:
// así no hace falta una consulta por tarjeta para pedir los tipos.
class PokemonWithTypes {
  PokemonWithTypes({
    required this.pokemon,
    required this.types,
    this.stats = const <PokemonStatEntry>[],
  });

  final PokemonEntry pokemon;
  final List<TypeEntry> types;

  // Solo se llena en el detalle; en la lista del catálogo queda vacío.
  final List<PokemonStatEntry> stats;
}

// DAO del catálogo: lecturas reactivas para la UI y escrituras por página
// para la sincronización (ADR-0003).
@DriftAccessor(
  tables: [
    Pokemons,
    PokeTypes,
    PokemonTypes,
    PokemonStats,
    TypeEfficacies,
    SyncMetadata,
  ],
)
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

  // ¿Hay al menos una fila de efectividades? (Mirar solo una basta.)
  Future<bool> hasEfficacies() async {
    final rows = await (select(typeEfficacies)..limit(1)).get();
    return rows.isNotEmpty;
  }

  // Toda la tabla de efectividades. Emite de nuevo si cambia (por ejemplo,
  // cuando termina la primera descarga con el detalle ya abierto).
  Stream<List<TypeEfficacyEntry>> watchTypeEfficacies() {
    return select(typeEfficacies).watch();
  }

  // Todos los tipos guardados (id y nombre). Los usa la pantalla de matchups
  // para poner nombre a cada tipo atacante.
  Stream<List<TypeEntry>> watchTypes() {
    return select(pokeTypes).watch();
  }

  // Guarda toda la tabla y el estado en una sola transacción: o queda la
  // tabla completa con su estado "ok", o no queda nada.
  Future<void> saveEfficacies(
    List<TypeEfficaciesCompanion> rows,
    SyncMetadataCompanion syncState,
  ) {
    return transaction(() async {
      await batch((b) {
        // Upsert: la clave es (tipo atacante, tipo defensor), no se duplica.
        b.insertAllOnConflictUpdate(typeEfficacies, rows);
      });
      await into(syncMetadata).insertOnConflictUpdate(syncState);
    });
  }

  // Guarda una página completa en una sola transacción (PS-07, PA-09).
  // Si la app se cierra a mitad, no queda nada a medias.
  Future<void> savePage({
    required List<PokeTypesCompanion> types,
    required List<PokemonsCompanion> pokemons,
    required List<PokemonTypesCompanion> pokemonTypes,
    required SyncMetadataCompanion syncState,
    List<PokemonStatsCompanion> stats = const [],
  }) {
    return transaction(() async {
      await batch((b) {
        // Primero los tipos: las relaciones los referencian (clave foránea).
        b.insertAllOnConflictUpdate(pokeTypes, types);
        // Upsert, nunca insertOrReplace: borrar una fila dispararía las
        // cascadas hacia tipos y habilidades (ADR-0003).
        b.insertAllOnConflictUpdate(this.pokemons, pokemons);
        // Los stats van DESPUÉS de los Pokémon (clave foránea). Upsert: si ya
        // existían, se actualizan sin duplicar (la clave es pokemonId+statId).
        b.insertAllOnConflictUpdate(pokemonStats, stats);
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

  // Un solo Pokémon con sus tipos y sus stats, en UNA consulta (detalle).
  // El JOIN devuelve una fila por cada combinación (tipo, stat): un Pokémon
  // con 2 tipos y 6 stats da 12 filas. Por eso, al leerlas, cada tipo y cada
  // stat se guardan una sola vez.
  // Devuelve null si ese Pokémon todavía no está guardado.
  // Drift vuelve a emitir cuando cambia cualquiera de las cuatro tablas.
  Stream<PokemonWithTypes?> watchPokemonWithTypes(int id) {
    final query =
        select(pokemons).join([
            leftOuterJoin(
              pokemonTypes,
              pokemonTypes.pokemonId.equalsExp(pokemons.id),
            ),
            leftOuterJoin(
              pokeTypes,
              pokeTypes.id.equalsExp(pokemonTypes.typeId),
            ),
            leftOuterJoin(
              pokemonStats,
              pokemonStats.pokemonId.equalsExp(pokemons.id),
            ),
          ])
          ..where(pokemons.id.equals(id))
          ..orderBy([
            OrderingTerm.asc(pokemonTypes.slot),
            OrderingTerm.asc(pokemonStats.statId),
          ]);

    return query.watch().map((rows) {
      // Sin filas: ese id no existe en la base.
      if (rows.isEmpty) {
        return null;
      }

      final pokemon = rows.first.readTable(pokemons);
      final types = <TypeEntry>[];
      final stats = <PokemonStatEntry>[];
      // Ids ya agregados, para no repetir por la multiplicación del JOIN.
      final seenTypeIds = <int>{};
      final seenStatIds = <int>{};

      for (final row in rows) {
        final type = row.readTableOrNull(pokeTypes);
        // Set.add devuelve false si el id ya estaba.
        if (type != null && seenTypeIds.add(type.id)) {
          types.add(type);
        }

        final stat = row.readTableOrNull(pokemonStats);
        if (stat != null && seenStatIds.add(stat.statId)) {
          stats.add(stat);
        }
      }
      return PokemonWithTypes(pokemon: pokemon, types: types, stats: stats);
    });
  }

  // Catálogo filtrado y ordenado, desde la base local (RF-FIL-05, PA-05).
  // Cada Pokémon aparece una sola vez, aunque tenga varios tipos que coincidan.
  Stream<List<PokemonWithTypes>> watchCatalogoFiltrado(CatalogoQuery query) {
    final consulta = select(pokemons).join([
      leftOuterJoin(
        pokemonTypes,
        pokemonTypes.pokemonId.equalsExp(pokemons.id),
      ),
      leftOuterJoin(pokeTypes, pokeTypes.id.equalsExp(pokemonTypes.typeId)),
    ])..where(_condicionDelFiltro(query));

    // El criterio elegido va primero. Después id y slot, para que los tipos
    // de cada Pokémon queden juntos y en orden.
    consulta.orderBy([
      _terminoDeOrden(query.orden),
      OrderingTerm.asc(pokemons.id),
      OrderingTerm.asc(pokemonTypes.slot),
    ]);

    return consulta.watch().map((rows) {
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

  // Condición WHERE: cada filtro activo se suma con &.
  Expression<bool> _condicionDelFiltro(CatalogoQuery query) {
    Expression<bool> condicion = const Constant(true);

    if (query.nombre.isNotEmpty) {
      condicion &= pokemons.name.like('%${query.nombre.toLowerCase()}%');
    }
    if (query.generacionIds.isNotEmpty) {
      condicion &= pokemons.generationId.isIn(query.generacionIds);
    }
    if (query.tipoIds.isNotEmpty) {
      // El Pokémon tiene al menos uno de los tipos pedidos.
      condicion &= pokemons.id.isInQuery(
        selectOnly(pokemonTypes)
          ..addColumns([pokemonTypes.pokemonId])
          ..where(pokemonTypes.typeId.isIn(query.tipoIds)),
      );
    }
    return condicion;
  }

  // Criterio de orden. El total base es una subconsulta que suma los stats.
  OrderingTerm _terminoDeOrden(CatalogoOrden orden) {
    return switch (orden) {
      CatalogoOrden.numero => OrderingTerm.asc(pokemons.nationalDexNumber),
      CatalogoOrden.nombre => OrderingTerm.asc(pokemons.name),
      CatalogoOrden.totalBase => OrderingTerm.desc(
        subqueryExpression<int>(
          selectOnly(pokemonStats)
            ..addColumns([pokemonStats.baseStat.sum()])
            ..where(pokemonStats.pokemonId.equalsExp(pokemons.id)),
        ),
      ),
    };
  }
}
