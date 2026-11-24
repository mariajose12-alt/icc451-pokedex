import 'package:drift/drift.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/core/database/tables/favorites_table.dart';

part 'favorites_dao.g.dart';

/// DAO de favoritos. Son datos del usuario: la sincronización del catálogo
/// no los modifica (OF-21, PS-11).
@DriftAccessor(tables: [Favorites])
class FavoritesDao extends DatabaseAccessor<AppDatabase>
    with _$FavoritesDaoMixin {
  FavoritesDao(super.attachedDatabase);

  /// ¿Es favorito? distinct(): si cambia otro favorito, este no vuelve a
  /// emitir lo mismo.
  Stream<bool> watchIsFavorite(int pokemonId) {
    final query = select(favorites)
      ..where((row) => row.pokemonId.equals(pokemonId));
    return query.watch().map((rows) => rows.isNotEmpty).distinct();
  }

  Stream<Set<int>> watchFavoriteIds() {
    return select(favorites)
        .watch()
        .map((rows) => {for (final row in rows) row.pokemonId});
  }

  /// Agrega o quita en una sola transacción (PS-09): o se completa o no se
  /// hace nada. Primero se intenta borrar; si no había fila, se inserta.
  /// Devuelve true si quedó como favorito.
  Future<bool> toggle(int pokemonId) {
    return transaction(() async {
      final removed = await (delete(
        favorites,
      )..where((row) => row.pokemonId.equals(pokemonId))).go();
      if (removed > 0) {
        return false;
      }
      await into(favorites)
          .insert(FavoritesCompanion.insert(pokemonId: Value(pokemonId)));
      return true;
    });
  }
}
