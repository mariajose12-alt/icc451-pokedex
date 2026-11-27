// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_dao.dart';

// ignore_for_file: type=lint
mixin _$FavoritesDaoMixin on DatabaseAccessor<AppDatabase> {
  $PokemonsTable get pokemons => attachedDatabase.pokemons;
  $FavoritesTable get favorites => attachedDatabase.favorites;
  $PokeTypesTable get pokeTypes => attachedDatabase.pokeTypes;
  $PokemonTypesTable get pokemonTypes => attachedDatabase.pokemonTypes;
  FavoritesDaoManager get managers => FavoritesDaoManager(this);
}

class FavoritesDaoManager {
  final _$FavoritesDaoMixin _db;
  FavoritesDaoManager(this._db);
  $$PokemonsTableTableManager get pokemons =>
      $$PokemonsTableTableManager(_db.attachedDatabase, _db.pokemons);
  $$FavoritesTableTableManager get favorites =>
      $$FavoritesTableTableManager(_db.attachedDatabase, _db.favorites);
  $$PokeTypesTableTableManager get pokeTypes =>
      $$PokeTypesTableTableManager(_db.attachedDatabase, _db.pokeTypes);
  $$PokemonTypesTableTableManager get pokemonTypes =>
      $$PokemonTypesTableTableManager(_db.attachedDatabase, _db.pokemonTypes);
}
