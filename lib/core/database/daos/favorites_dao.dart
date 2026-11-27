import 'package:drift/drift.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/core/database/daos/catalogo_dao.dart';
import 'package:pokedex/core/database/tables/favorites_table.dart';
import 'package:pokedex/core/database/tables/poke_types_table.dart';
import 'package:pokedex/core/database/tables/pokemon_table.dart';
import 'package:pokedex/core/database/tables/pokemon_types_table.dart';

part 'favorites_dao.g.dart';

/// DAO de favoritos. Son datos del usuario: la sincronización del catálogo
/// no los modifica (OF-21, PS-11).
@DriftAccessor(tables: [Favorites, Pokemons, PokeTypes, PokemonTypes])
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

  /// Favoritos con sus datos y tipos, el más reciente primero.
  /// innerJoin con pokemons: un favorito siempre apunta a un Pokémon que
  /// existe (la clave foránea lo garantiza).
  /// leftOuterJoin con los tipos: un Pokémon sin tipos guardados no
  /// desaparece de la lista.
  Stream<List<PokemonWithTypes>> watchFavoritesWithTypes() {
    final query =
        select(favorites).join([
          innerJoin(pokemons, pokemons.id.equalsExp(favorites.pokemonId)),
          leftOuterJoin(
            pokemonTypes,
            pokemonTypes.pokemonId.equalsExp(pokemons.id),
          ),
          leftOuterJoin(pokeTypes, pokeTypes.id.equalsExp(pokemonTypes.typeId)),
        ])..orderBy([
          OrderingTerm.desc(favorites.createdAt),
          // Desempate: createdAt guarda segundos.
          OrderingTerm.desc(favorites.pokemonId),
          OrderingTerm.asc(pokemonTypes.slot),
        ]);

    return query.watch().map((rows) {
      // El mapa conserva el orden de inserción: el orden de la consulta.
      final byId = <int, PokemonWithTypes>{};
      for (final row in rows) {
        final pokemon = row.readTable(pokemons);
        final type = row.readTableOrNull(pokeTypes);
        final item = byId.putIfAbsent(
          pokemon.id,
          () => PokemonWithTypes(pokemon: pokemon, types: <TypeEntry>[]),
        );
        if (type != null) {
          item.types.add(type);
        }
      }
      return byId.values.toList();
    });
  }
}
