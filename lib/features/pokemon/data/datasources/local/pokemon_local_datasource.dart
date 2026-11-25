import 'package:drift/drift.dart' show Value;
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/core/database/daos/catalogo_dao.dart';
import 'package:pokedex/core/sync/sync_status.dart';
import 'package:pokedex/features/pokemon/data/models/pokemon_companion_mapper.dart';
import 'package:pokedex/features/pokemon/data/models/pokemon_dto.dart';
import 'package:pokedex/features/pokemon/data/models/pokemon_entry_mapper.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/data/models/type_efficacy_dto.dart';
import 'package:pokedex/features/pokemon/domain/entities/type_chart.dart';
import 'package:pokedex/features/pokemon/domain/entities/type_efficacy.dart';

import '../../../domain/entities/catalogo_query.dart';

/// Acceso a la base local (Drift) para el catálogo.
/// Es el único punto donde se mezclan DTOs, filas de Drift y entidades.
class PokemonLocalDataSource {
  PokemonLocalDataSource({required this._dao});

  final CatalogoDao _dao;

  /// Catálogo guardado, con tipos, como entidades del dominio.
  /// Emite de nuevo cada vez que la base cambia (OF-16).
  Stream<List<Pokemon>> watchCatalog() {
    return _dao.watchCatalogWithTypes().map((rows) {
      final result = <Pokemon>[];
      for (final row in rows) {
        result.add(row.toDomain());
      }
      return result;
    });
  }

  /// Un Pokémon guardado, con tipos, como entidad del dominio.
  /// Emite null si no existe y vuelve a emitir cuando la base cambia.
  Stream<Pokemon?> watchPokemon(int id) {
    // row?.toDomain(): si no hay fila, queda null; si hay, se convierte.
    return _dao.watchPokemonWithTypes(id).map((row) => row?.toDomain());
  }

  /// Id desde el cual hay que pedir la siguiente página.
  ///  - Nunca se sincronizó, o la última vez terminó bien: 0 (se empieza de
  ///    nuevo y el upsert actualiza lo que ya existe).
  ///  - Quedó a medias o falló: el cursor guardado (se reanuda, PS-07).
  Future<int> resumeCursor() async {
    final state = await _dao.readSyncState(SyncResources.catalog);

    // Sin registro, o la última vez terminó bien: se empieza de cero.
    if (state == null || state.status == SyncStatus.ok) {
      // Se deja escrito que esta corrida empieza en 0. Sin esto, si la
      // primera llamada falla, queda guardado el cursor viejo (p. ej. 1025)
      // y la próxima vez se daría el catálogo por completo sin estarlo.
      // lastSuccessfulAt se omite a propósito para conservar la fecha anterior.
      await _dao.saveSyncState(
        const SyncMetadataCompanion(
          resourceKey: Value(SyncResources.catalog),
          status: Value(SyncStatus.syncing),
          cursorOrOffset: Value('0'),
        ),
      );
      return 0;
    }

    // Quedó a medias o falló: se reanuda desde el cursor guardado (PS-07).
    return int.tryParse(state.cursorOrOffset ?? '') ?? 0;
  }

  /// Hay que sincronizar? Es true si nunca se sincronizó, si la última vez
  /// quedó a medias o falló, o si la última sincronización completa tiene
  /// [maxAge] o más (PS-03).
  Future<bool> isStale(Duration maxAge) async {
    final state = await _dao.readSyncState(SyncResources.catalog);

    // Sin registro, o la última no terminó bien: falta descargar.
    if (state == null || state.status != SyncStatus.ok) {
      return true;
    }

    final lastSuccess = state.lastSuccessfulAt;
    if (lastSuccess == null) {
      return true;
    }

    return DateTime.now().difference(lastSuccess) >= maxAge;
  }

  /// Guarda una página y su cursor en una sola transacción.
  /// Si [isLast] es true, el recurso queda como `ok` con la fecha de ahora.
  Future<void> savePage(List<PokemonDto> items, {required bool isLast}) {
    final now = DateTime.now();
    final rows = pageToCompanions(items, now);

    // La fecha de última sincronización exitosa solo se actualiza al terminar.
    // En las páginas intermedias se deja ausente para conservar la anterior.
    final Value<DateTime?> lastSuccessfulAt = isLast
        ? Value(now)
        : const Value.absent();

    return _dao.savePage(
      types: rows.types,
      pokemons: rows.pokemons,
      pokemonTypes: rows.pokemonTypes,
      stats: rows.stats,
      syncState: SyncMetadataCompanion(
        resourceKey: const Value(SyncResources.catalog),
        status: Value(isLast ? SyncStatus.ok : SyncStatus.syncing),
        cursorOrOffset: Value('${items.last.id}'),
        lastSuccessfulAt: lastSuccessfulAt,
      ),
    );
  }

  /// La API no tiene más Pokémon después del cursor: la sincronización terminó.
  Future<void> markComplete() {
    return _dao.saveSyncState(
      SyncMetadataCompanion(
        resourceKey: const Value(SyncResources.catalog),
        status: const Value(SyncStatus.ok),
        lastSuccessfulAt: Value(DateTime.now()),
      ),
    );
  }

  /// Marca la sincronización como fallida. No toca el catálogo ni el cursor,
  /// así que lo ya descargado sigue disponible y se puede reanudar (OF-04).
  Future<void> markFailed() {
    return _dao.saveSyncState(
      const SyncMetadataCompanion(
        resourceKey: Value(SyncResources.catalog),
        status: Value(SyncStatus.failed),
      ),
    );
  }

  /// ¿Ya están descargadas las efectividades? Se exige el estado "ok" Y que
  /// haya filas: si alguien borra la tabla, se vuelve a descargar.
  Future<bool> hasEfficacies() async {
    final state = await _dao.readSyncState(SyncResources.typeEfficacies);
    if (state == null || state.status != SyncStatus.ok) {
      return false;
    }
    return _dao.hasEfficacies();
  }

  /// Guarda la tabla de efectividades y deja el recurso en "ok".
  Future<void> saveEfficacies(List<TypeEfficacyDto> items) {
    final rows = <TypeEfficaciesCompanion>[];
    for (final item in items) {
      rows.add(
        TypeEfficaciesCompanion.insert(
          damageTypeId: item.damageTypeId,
          targetTypeId: item.targetTypeId,
          damageFactor: item.damageFactor,
        ),
      );
    }

    return _dao.saveEfficacies(
      rows,
      SyncMetadataCompanion(
        resourceKey: const Value(SyncResources.typeEfficacies),
        status: const Value(SyncStatus.ok),
        lastSuccessfulAt: Value(DateTime.now()),
      ),
    );
  }

  /// Tabla de efectividades como entidad del dominio. Emite una tabla vacía
  /// mientras no se haya descargado y otra completa cuando llega.
  Stream<TypeChart> watchTypeChart() {
    return _dao.watchTypeEfficacies().map((rows) {
      final entries = <TypeEfficacy>[];
      for (final row in rows) {
        entries.add(
          TypeEfficacy(
            damageTypeId: row.damageTypeId,
            targetTypeId: row.targetTypeId,
            damageFactor: row.damageFactor,
          ),
        );
      }
      return TypeChart(entries);
    });
  }

  /// Nombre de cada tipo guardado, por id: {12: 'grass', 10: 'fire', ...}.
  Stream<Map<int, String>> watchTypeNames() {
    return _dao.watchTypes().map((rows) {
      final names = <int, String>{};
      for (final row in rows) {
        names[row.id] = row.name;
      }
      return names;
    });
  }

  /// Catálogo filtrado y ordenado, como entidades del dominio.
  Stream<List<Pokemon>> watchCatalogoFiltrado(CatalogoQuery query) {
    return _dao.watchCatalogoFiltrado(query).map((rows) {
      final result = <Pokemon>[];
      for (final row in rows) {
        result.add(row.toDomain());
      }
      return result;
    });
  }
}
