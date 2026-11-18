// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detalle_dao.dart';

// ignore_for_file: type=lint
mixin _$DetalleDaoMixin on DatabaseAccessor<AppDatabase> {
  $PokemonsTable get pokemons => attachedDatabase.pokemons;
  $PokeTypesTable get pokeTypes => attachedDatabase.pokeTypes;
  $PokemonTypesTable get pokemonTypes => attachedDatabase.pokemonTypes;
  $PokemonStatsTable get pokemonStats => attachedDatabase.pokemonStats;
  $AbilitiesTable get abilities => attachedDatabase.abilities;
  $PokemonAbilitiesTable get pokemonAbilities =>
      attachedDatabase.pokemonAbilities;
  $PokemonEggGroupsTable get pokemonEggGroups =>
      attachedDatabase.pokemonEggGroups;
  $EvolutionNodesTable get evolutionNodes => attachedDatabase.evolutionNodes;
  $PokemonFormsTable get pokemonForms => attachedDatabase.pokemonForms;
  $PokemonFormTypesTable get pokemonFormTypes =>
      attachedDatabase.pokemonFormTypes;
  $MovesTable get moves => attachedDatabase.moves;
  $VersionGroupsTable get versionGroups => attachedDatabase.versionGroups;
  $PokemonMovesTable get pokemonMoves => attachedDatabase.pokemonMoves;
  $SyncMetadataTable get syncMetadata => attachedDatabase.syncMetadata;
  DetalleDaoManager get managers => DetalleDaoManager(this);
}

class DetalleDaoManager {
  final _$DetalleDaoMixin _db;
  DetalleDaoManager(this._db);
  $$PokemonsTableTableManager get pokemons =>
      $$PokemonsTableTableManager(_db.attachedDatabase, _db.pokemons);
  $$PokeTypesTableTableManager get pokeTypes =>
      $$PokeTypesTableTableManager(_db.attachedDatabase, _db.pokeTypes);
  $$PokemonTypesTableTableManager get pokemonTypes =>
      $$PokemonTypesTableTableManager(_db.attachedDatabase, _db.pokemonTypes);
  $$PokemonStatsTableTableManager get pokemonStats =>
      $$PokemonStatsTableTableManager(_db.attachedDatabase, _db.pokemonStats);
  $$AbilitiesTableTableManager get abilities =>
      $$AbilitiesTableTableManager(_db.attachedDatabase, _db.abilities);
  $$PokemonAbilitiesTableTableManager get pokemonAbilities =>
      $$PokemonAbilitiesTableTableManager(
        _db.attachedDatabase,
        _db.pokemonAbilities,
      );
  $$PokemonEggGroupsTableTableManager get pokemonEggGroups =>
      $$PokemonEggGroupsTableTableManager(
        _db.attachedDatabase,
        _db.pokemonEggGroups,
      );
  $$EvolutionNodesTableTableManager get evolutionNodes =>
      $$EvolutionNodesTableTableManager(
        _db.attachedDatabase,
        _db.evolutionNodes,
      );
  $$PokemonFormsTableTableManager get pokemonForms =>
      $$PokemonFormsTableTableManager(_db.attachedDatabase, _db.pokemonForms);
  $$PokemonFormTypesTableTableManager get pokemonFormTypes =>
      $$PokemonFormTypesTableTableManager(
        _db.attachedDatabase,
        _db.pokemonFormTypes,
      );
  $$MovesTableTableManager get moves =>
      $$MovesTableTableManager(_db.attachedDatabase, _db.moves);
  $$VersionGroupsTableTableManager get versionGroups =>
      $$VersionGroupsTableTableManager(_db.attachedDatabase, _db.versionGroups);
  $$PokemonMovesTableTableManager get pokemonMoves =>
      $$PokemonMovesTableTableManager(_db.attachedDatabase, _db.pokemonMoves);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db.attachedDatabase, _db.syncMetadata);
}
