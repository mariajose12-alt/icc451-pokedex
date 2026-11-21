import 'package:drift/drift.dart';

import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/core/database/tables/favorites_table.dart';

part 'favorites_dao.g.dart';

@DriftAccessor(tables: [Favorites])
class FavoritesDao extends DatabaseAccessor<AppDatabase>
    with _$FavoritesDaoMixin {
  FavoritesDao(super.db);

  /// Emite la lista de favoritos ante cada cambio.
  Stream<List<FavoriteEntry>> watchFavorites() => select(favorites).watch();

  /// Emite true si el Pokémon es favorito.
  Stream<bool> watchIsFavorite(int pokemonId) =>
      (select(favorites)..where((t) => t.pokemonId.equals(pokemonId)))
          .watch()
          .map((rows) => rows.isNotEmpty);

  /// Agrega el favorito. Sin efecto si ya existe (PS-06).
  Future<void> addFavorite(int pokemonId) => into(favorites).insert(
    FavoritesCompanion.insert(pokemonId: Value(pokemonId)),
    mode: InsertMode.insertOrIgnore,
  );

  /// Quita el favorito. Devuelve las filas eliminadas.
  Future<int> removeFavorite(int pokemonId) =>
      (delete(favorites)..where((t) => t.pokemonId.equals(pokemonId))).go();
}
