import 'package:pokedex/core/database/daos/catalogo_dao.dart';
import 'package:pokedex/features/settings/domain/repositories/saved_pokemon_repository.dart';

/// Lee de la base local (Drift). Nunca llama a la red.
class DriftSavedPokemonRepository implements SavedPokemonRepository {
  DriftSavedPokemonRepository({required this._dao});

  final CatalogoDao _dao;

  @override
  Stream<int> watchCount() => _dao.watchCount();

  @override
  Future<List<String>> randomSpriteUrls(int limit) =>
      _dao.randomSpriteUrls(limit);
}
