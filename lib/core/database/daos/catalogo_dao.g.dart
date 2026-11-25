// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalogo_dao.dart';

// ignore_for_file: type=lint
mixin _$CatalogoDaoMixin on DatabaseAccessor<AppDatabase> {
  $PokemonsTable get pokemons => attachedDatabase.pokemons;
  $PokeTypesTable get pokeTypes => attachedDatabase.pokeTypes;
  $PokemonTypesTable get pokemonTypes => attachedDatabase.pokemonTypes;
  $PokemonStatsTable get pokemonStats => attachedDatabase.pokemonStats;
  $TypeEfficaciesTable get typeEfficacies => attachedDatabase.typeEfficacies;
  $SyncMetadataTable get syncMetadata => attachedDatabase.syncMetadata;
  CatalogoDaoManager get managers => CatalogoDaoManager(this);
}

class CatalogoDaoManager {
  final _$CatalogoDaoMixin _db;
  CatalogoDaoManager(this._db);
  $$PokemonsTableTableManager get pokemons =>
      $$PokemonsTableTableManager(_db.attachedDatabase, _db.pokemons);
  $$PokeTypesTableTableManager get pokeTypes =>
      $$PokeTypesTableTableManager(_db.attachedDatabase, _db.pokeTypes);
  $$PokemonTypesTableTableManager get pokemonTypes =>
      $$PokemonTypesTableTableManager(_db.attachedDatabase, _db.pokemonTypes);
  $$PokemonStatsTableTableManager get pokemonStats =>
      $$PokemonStatsTableTableManager(_db.attachedDatabase, _db.pokemonStats);
  $$TypeEfficaciesTableTableManager get typeEfficacies =>
      $$TypeEfficaciesTableTableManager(
        _db.attachedDatabase,
        _db.typeEfficacies,
      );
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db.attachedDatabase, _db.syncMetadata);
}
