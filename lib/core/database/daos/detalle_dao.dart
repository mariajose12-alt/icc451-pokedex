import 'dart:async';

import 'package:drift/drift.dart';
import 'package:pokedex/core/sync/sync_status.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/core/database/tables/abilities_table.dart';
import 'package:pokedex/core/database/tables/evolution_nodes_table.dart';
import 'package:pokedex/core/database/tables/moves_table.dart';
import 'package:pokedex/core/database/tables/poke_types_table.dart';
import 'package:pokedex/core/database/tables/pokemon_abilities_table.dart';
import 'package:pokedex/core/database/tables/pokemon_egg_groups_table.dart';
import 'package:pokedex/core/database/tables/pokemon_form_types_table.dart';
import 'package:pokedex/core/database/tables/pokemon_forms_table.dart';
import 'package:pokedex/core/database/tables/pokemon_moves_table.dart';
import 'package:pokedex/core/database/tables/pokemon_stats_table.dart';
import 'package:pokedex/core/database/tables/pokemon_table.dart';
import 'package:pokedex/core/database/tables/pokemon_types_table.dart';
import 'package:pokedex/core/database/tables/sync_metadata_table.dart';
import 'package:pokedex/core/database/tables/version_groups_table.dart';

part 'detalle_dao.g.dart';

/// Todas las filas que salen del detalle de UN Pokémon, ya convertidas a lo
/// que entiende la base. Se guardan juntas en [DetalleDao.saveDetail].
class PokemonDetailRows {
  const PokemonDetailRows({
    required this.pokemonId,
    required this.types,
    required this.pokemons,
    required this.pokemonTypes,
    required this.stats,
    required this.abilities,
    required this.pokemonAbilities,
    required this.eggGroups,
    required this.evolutionChainId,
    required this.evolutionNodes,
    required this.forms,
    required this.formTypes,
    required this.moves,
    required this.versionGroups,
    required this.pokemonMoves,
  });

  final int pokemonId;
  final List<PokeTypesCompanion> types;
  final List<PokemonsCompanion> pokemons;
  final List<PokemonTypesCompanion> pokemonTypes;
  final List<PokemonStatsCompanion> stats;
  final List<AbilitiesCompanion> abilities;
  final List<PokemonAbilitiesCompanion> pokemonAbilities;
  final List<PokemonEggGroupsCompanion> eggGroups;

  /// Null si PokeAPI no mandó cadena evolutiva.
  final int? evolutionChainId;
  final List<EvolutionNodesCompanion> evolutionNodes;
  final List<PokemonFormsCompanion> forms;
  final List<PokemonFormTypesCompanion> formTypes;
  final List<MovesCompanion> moves;
  final List<VersionGroupsCompanion> versionGroups;
  final List<PokemonMovesCompanion> pokemonMoves;
}

/// DAO del detalle: guarda lo que se descarga al abrir un Pokémon.
@DriftAccessor(
  tables: [
    Pokemons,
    PokeTypes,
    PokemonTypes,
    PokemonStats,
    Abilities,
    PokemonAbilities,
    PokemonEggGroups,
    EvolutionNodes,
    PokemonForms,
    PokemonFormTypes,
    Moves,
    VersionGroups,
    PokemonMoves,
    SyncMetadata,
  ],
)
class DetalleDao extends DatabaseAccessor<AppDatabase> with _$DetalleDaoMixin {
  DetalleDao(super.db);

  /// Estado de la última actualización de un recurso (null si no hay).
  Future<SyncMetadataEntry?> readSyncState(String resourceKey) {
    return (select(
      syncMetadata,
    )..where((s) => s.resourceKey.equals(resourceKey))).getSingleOrNull();
  }

  /// Guarda solo el estado (por ejemplo, 'failed'); lo que venga ausente se
  /// conserva, así la fecha del último éxito no se pierde.
  Future<void> saveSyncState(SyncMetadataCompanion state) {
    return into(syncMetadata).insertOnConflictUpdate(state);
  }

  /// Guarda el detalle completo y el estado en UNA transacción (PA-09).
  ///
  /// Orden: primero lo que otras filas referencian (tipos, Pokémon, habilidades,
  /// movimientos, grupos de versión) y después las relaciones.
  ///
  /// Los hijos del Pokémon se REEMPLAZAN (se borran y se insertan de nuevo):
  /// así, si en la base se agregó o quitó algo, queda lo que dice PokeAPI
  /// (OF-19). La fila de pokemons NUNCA se borra (borrarla dispararía cascadas)
  /// y favorites no se toca (OF-21).
  Future<void> saveDetail(
    PokemonDetailRows rows,
    SyncMetadataCompanion syncState,
  ) {
    return transaction(() async {
      final id = rows.pokemonId;

      // 1. Lo que otras filas referencian. Upsert: no duplica (PS-06).
      await batch((b) {
        b.insertAllOnConflictUpdate(pokeTypes, rows.types);
        b.insertAllOnConflictUpdate(pokemons, rows.pokemons);
        b.insertAllOnConflictUpdate(abilities, rows.abilities);
        b.insertAllOnConflictUpdate(moves, rows.moves);
        b.insertAllOnConflictUpdate(versionGroups, rows.versionGroups);
      });

      // 2. Se borran los hijos de ESTE Pokémon para reemplazarlos.
      await (delete(pokemonTypes)..where((t) => t.pokemonId.equals(id))).go();
      await (delete(pokemonStats)..where((t) => t.pokemonId.equals(id))).go();
      await (delete(
        pokemonAbilities,
      )..where((t) => t.pokemonId.equals(id))).go();
      await (delete(
        pokemonEggGroups,
      )..where((t) => t.pokemonId.equals(id))).go();
      await (delete(pokemonMoves)..where((t) => t.pokemonId.equals(id))).go();

      // La cadena evolutiva y las formas no cuelgan de pokemons por clave
      // foránea: se reemplazan por su propio identificador.
      final chainId = rows.evolutionChainId;
      if (chainId != null) {
        await (delete(
          evolutionNodes,
        )..where((n) => n.chainId.equals(chainId))).go();
      }
      final oldForms = await (select(
        pokemonForms,
      )..where((f) => f.speciesId.equals(id))).get();
      final oldFormIds = [for (final form in oldForms) form.id];
      await (delete(
        pokemonFormTypes,
      )..where((t) => t.formId.isIn(oldFormIds))).go();
      await (delete(pokemonForms)..where((f) => f.speciesId.equals(id))).go();

      // 3. Se insertan las relaciones nuevas.
      await batch((b) {
        b.insertAllOnConflictUpdate(pokemonTypes, rows.pokemonTypes);
        b.insertAllOnConflictUpdate(pokemonStats, rows.stats);
        b.insertAllOnConflictUpdate(pokemonAbilities, rows.pokemonAbilities);
        b.insertAllOnConflictUpdate(pokemonEggGroups, rows.eggGroups);
        b.insertAllOnConflictUpdate(evolutionNodes, rows.evolutionNodes);
        b.insertAllOnConflictUpdate(pokemonForms, rows.forms);
        b.insertAllOnConflictUpdate(pokemonFormTypes, rows.formTypes);
        b.insertAllOnConflictUpdate(pokemonMoves, rows.pokemonMoves);
      });

      // 4. El estado, dentro de la misma transacción: si algo falló arriba,
      // no queda marcado como 'ok'.
      await into(syncMetadata).insertOnConflictUpdate(syncState);
    });
  }

  /// Observa los datos extra de un Pokémon: emite al abrir y cada vez que
  /// cambia alguna de las tablas que se leen.
  Stream<PokemonExtrasRows> watchExtras(int pokemonId) async* {
    // Los avisos de cambio se guardan en este buffer.
    final changes = StreamController<void>();

    // Primero nos suscribimos a los cambios. Así, si algo se guarda mientras
    // se hace la primera lectura, el aviso queda en espera y no se pierde.
    final subscription = attachedDatabase
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            abilities,
            pokemonAbilities,
            pokemonEggGroups,
            evolutionNodes,
            pokemonForms,
            pokemonFormTypes,
            syncMetadata,
          ]),
        )
        .listen((_) => changes.add(null));

    try {
      yield await _readExtras(pokemonId);
      await for (final _ in changes.stream) {
        yield await _readExtras(pokemonId);
      }
    } finally {
      // Se ejecuta también cuando la pantalla cancela el stream.
      await subscription.cancel();
      // Sin await: close() solo termina si alguien escucha, y aquí ya no.
      unawaited(changes.close());
    }
  }

  Future<PokemonExtrasRows> _readExtras(int pokemonId) async {
    // ¿Se descargó alguna vez con éxito?
    final state = await readSyncState(SyncResources.detail(pokemonId));
    final downloaded = state?.lastSuccessfulAt != null;

    // Habilidades de este Pokémon: las normales primero, la oculta al final.
    final abilityQuery =
        select(pokemonAbilities).join([
            innerJoin(
              abilities,
              abilities.id.equalsExp(pokemonAbilities.abilityId),
            ),
          ])
          ..where(pokemonAbilities.pokemonId.equals(pokemonId))
          ..orderBy([
            OrderingTerm.asc(pokemonAbilities.isHidden),
            OrderingTerm.asc(pokemonAbilities.abilityId),
          ]);
    final abilityList = <AbilityWithHidden>[];
    for (final row in await abilityQuery.get()) {
      abilityList.add(
        AbilityWithHidden(
          ability: row.readTable(abilities),
          isHidden: row.readTable(pokemonAbilities).isHidden,
        ),
      );
    }

    // Egg groups.
    final eggRows =
        await (select(pokemonEggGroups)
              ..where((g) => g.pokemonId.equals(pokemonId))
              ..orderBy([(g) => OrderingTerm.asc(g.eggGroup)]))
            .get();
    final eggList = [for (final row in eggRows) row.eggGroup];

    // Cadena evolutiva: se busca la cadena donde está la especie y se traen
    // todas las especies de esa cadena.
    final own = await (select(
      evolutionNodes,
    )..where((n) => n.speciesId.equals(pokemonId))).get();
    var chainNodes = <EvolutionNodeEntry>[];
    if (own.isNotEmpty) {
      final chainId = own.first.chainId;
      chainNodes =
          await (select(evolutionNodes)
                ..where((n) => n.chainId.equals(chainId))
                ..orderBy([(n) => OrderingTerm.asc(n.speciesId)]))
              .get();
    }

    // Formas y sus tipos.
    final formList =
        await (select(pokemonForms)
              ..where((f) => f.speciesId.equals(pokemonId))
              ..orderBy([(f) => OrderingTerm.asc(f.id)]))
            .get();
    final formIds = [for (final form in formList) form.id];
    final typeRows =
        await (select(pokemonFormTypes)
              ..where((t) => t.formId.isIn(formIds))
              ..orderBy([(t) => OrderingTerm.asc(t.slot)]))
            .get();
    final typeIdsByForm = <int, List<int>>{};
    for (final row in typeRows) {
      (typeIdsByForm[row.formId] ??= <int>[]).add(row.typeId);
    }

    return PokemonExtrasRows(
      downloaded: downloaded,
      abilities: abilityList,
      eggGroups: eggList,
      evolutionNodes: chainNodes,
      forms: formList,
      formTypeIds: typeIdsByForm,
    );
  }
}

/// Una habilidad junto con si es oculta para ESTE Pokémon.
class AbilityWithHidden {
  const AbilityWithHidden({required this.ability, required this.isHidden});

  final AbilityEntry ability;
  final bool isHidden;
}

/// Lo que lee [DetalleDao.watchExtras]: filas de la base, aún sin convertir
/// al dominio.
class PokemonExtrasRows {
  const PokemonExtrasRows({
    required this.downloaded,
    required this.abilities,
    required this.eggGroups,
    required this.evolutionNodes,
    required this.forms,
    required this.formTypeIds,
  });

  final bool downloaded;
  final List<AbilityWithHidden> abilities;
  final List<String> eggGroups;
  final List<EvolutionNodeEntry> evolutionNodes;
  final List<PokemonFormEntry> forms;

  /// Ids de tipo de cada forma, por id de forma, en orden de slot.
  final Map<int, List<int>> formTypeIds;
}
