import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/core/database/daos/detalle_dao.dart';
import 'package:pokedex/core/sync/sync_status.dart';
import 'package:pokedex/features/pokemon/data/models/pokemon_detail_dto.dart';
import 'package:pokedex/features/pokemon/data/models/pokemon_detail_mapper.dart';
import 'package:pokedex/features/pokemon/data/models/pokemon_extras_mapper.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_extras.dart';

/// Acceso a la base local para el detalle de un Pokémon.
class PokemonDetailLocalDataSource {
  PokemonDetailLocalDataSource({required this._dao});

  final DetalleDao _dao;

  /// ¿Se consultó con éxito hace menos de [maxAge]? Si es así no hace falta
  /// volver a pedirlo (PS-03).
  Future<bool> isFresh(int pokemonId, Duration maxAge) async {
    final state = await _dao.readSyncState(SyncResources.detail(pokemonId));

    // Sin registro, o la última vez falló: hay que pedirlo.
    if (state == null || state.status != SyncStatus.ok) {
      return false;
    }

    final lastSuccess = state.lastSuccessfulAt;
    if (lastSuccess == null) {
      return false;
    }

    return DateTime.now().difference(lastSuccess) < maxAge;
  }

  /// Guarda el detalle y deja su estado en 'ok' con la fecha de ahora.
  /// Antes de sobrescribir compara con lo guardado: si alguien alteró el
  /// catálogo en la base, se registra la diferencia y se restaura con la
  /// versión de PokeAPI (OF-19). Los favoritos no se tocan (OF-21).
  Future<void> save(PokemonDetailDto dto) async {
    await _reportDifferences(dto);

    final now = DateTime.now();
    await _dao.saveDetail(
      detailToRows(dto, now),
      SyncMetadataCompanion(
        resourceKey: Value(SyncResources.detail(dto.base.id)),
        status: const Value(SyncStatus.ok),
        lastSuccessfulAt: Value(now),
      ),
    );
  }

  Future<void> _reportDifferences(PokemonDetailDto dto) async {
    final id = dto.base.id;
    final local = await _dao.readBase(id);
    // Primera vez que se guarda: no hay nada con qué comparar.
    if (local == null) {
      return;
    }

    // Los tipos remotos, en orden de slot, para compararlos con los locales.
    final remoteTypes = List.of(dto.base.types)
      ..sort((a, b) => a.slot.compareTo(b.slot));
    final remoteTypeIds = [for (final t in remoteTypes) t.typeId];

    final differences = <String>[];
    if (local.name != dto.base.name) {
      differences.add('nombre "${local.name}" -> "${dto.base.name}"');
    }
    if (!listEquals(local.typeIds, remoteTypeIds)) {
      differences.add('tipos ${local.typeIds} -> $remoteTypeIds');
    }

    if (differences.isNotEmpty) {
      debugPrint(
        'Integridad: #$id difiere de PokeAPI (${differences.join('; ')}). '
            'Se restaura con la versión remota (OF-19).',
      );
    }
  }

  /// Anota que el último intento falló. No toca los datos guardados ni la
  /// fecha del último éxito.
  Future<void> markFailed(int pokemonId) {
    return _dao.saveSyncState(
      SyncMetadataCompanion(
        resourceKey: Value(SyncResources.detail(pokemonId)),
        status: const Value(SyncStatus.failed),
      ),
    );
  }

  /// Lo descargado de un Pokémon, como entidades del dominio. Emite de nuevo
  /// cada vez que la base cambia (OF-16).
  Stream<PokemonExtras> watchExtras(int pokemonId) {
    return _dao.watchExtras(pokemonId).map((rows) => rows.toDomain());
  }
}
