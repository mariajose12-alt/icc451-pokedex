import 'package:pokedex/core/database/daos/favorites_dao.dart';
import 'package:pokedex/features/favorites/domain/repositories/favorites_repository.dart';

/// Favoritos sobre la base local (Drift). Es una capa fina: la lógica de la
/// transacción vive en el DAO.
class OfflineFirstFavoritesRepository implements FavoritesRepository {
  const OfflineFirstFavoritesRepository({required this._dao});

  final FavoritesDao _dao;

  @override
  Stream<bool> watchIsFavorite(int pokemonId) =>
      _dao.watchIsFavorite(pokemonId);

  @override
  Stream<Set<int>> watchFavoriteIds() => _dao.watchFavoriteIds();

  @override
  Future<bool> toggle(int pokemonId) => _dao.toggle(pokemonId);
}
