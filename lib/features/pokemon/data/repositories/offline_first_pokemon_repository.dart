import 'package:pokedex/core/errors/failure_mapper.dart';
import 'package:pokedex/core/network/network_exceptions.dart';
import 'package:pokedex/features/pokemon/data/datasources/local/pokemon_local_datasource.dart';
import 'package:pokedex/features/pokemon/data/sync/catalog_sync_coordinator.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_repository.dart';

/// Repositorio real del catálogo (Offline-First, ADR-0001).
///  - Leer: SOLO desde la base local.
///  - Actualizar: la red solo escribe en la base; la pantalla se entera
///    porque el stream de lectura emite de nuevo.
class OfflineFirstPokemonRepository implements PokemonRepository {
  OfflineFirstPokemonRepository({
    required this._local,
    required this._sync,
    this.catalogMaxAge = defaultCatalogMaxAge,
  });

  /// Vigencia del catálogo (PS-03): pasado este tiempo se considera viejo.
  static const Duration defaultCatalogMaxAge = Duration(hours: 24);

  final PokemonLocalDataSource _local;
  final CatalogSyncCoordinator _sync;
  final Duration catalogMaxAge;

  @override
  Stream<List<Pokemon>> watchCatalog() => _local.watchCatalog();

  @override
  Future<void> refreshCatalog({bool onlyIfStale = false}) async {
    // Actualización automática con datos vigentes: no se gasta ninguna llamada.
    if (onlyIfStale && !await _local.isStale(catalogMaxAge)) {
      return;
    }

    try {
      await _sync.sync();
    } on PokeApiException catch (error) {
      throw error.toFailure();
    }
  }
}
