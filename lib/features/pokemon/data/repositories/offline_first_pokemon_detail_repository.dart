import 'package:pokedex/core/errors/failure_mapper.dart';
import 'package:pokedex/core/network/network_exceptions.dart';
import 'package:pokedex/features/pokemon/data/datasources/local/pokemon_detail_local_datasource.dart';
import 'package:pokedex/features/pokemon/data/sync/pokemon_detail_sync_coordinator.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_extras.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_detail_repository.dart';

/// Repositorio real del detalle: leer SOLO de la base local; la red solo
/// escribe en la base (OF-16).
class OfflineFirstPokemonDetailRepository implements PokemonDetailRepository {
  OfflineFirstPokemonDetailRepository({
    required this._sync,
    required this._local,
  });

  final PokemonDetailSyncCoordinator _sync;
  final PokemonDetailLocalDataSource _local;

  @override
  Future<void> refreshDetail(int pokemonId) async {
    try {
      await _sync.refresh(pokemonId);
    } on PokeApiException catch (error) {
      // La capa de dominio solo conoce Failure, no errores de infraestructura.
      throw error.toFailure();
    }
  }

  @override
  Stream<PokemonExtras> watchExtras(int pokemonId) {
    return _local.watchExtras(pokemonId);
  }
}
