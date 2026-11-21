import 'package:drift/drift.dart' show Value;
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
  Future<void> save(PokemonDetailDto dto) {
    final now = DateTime.now();
    return _dao.saveDetail(
      detailToRows(dto, now),
      SyncMetadataCompanion(
        resourceKey: Value(SyncResources.detail(dto.base.id)),
        status: const Value(SyncStatus.ok),
        lastSuccessfulAt: Value(now),
      ),
    );
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
