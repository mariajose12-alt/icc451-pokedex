// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trivia_dao.dart';

// ignore_for_file: type=lint
mixin _$TriviaDaoMixin on DatabaseAccessor<AppDatabase> {
  $PokemonsTable get pokemons => attachedDatabase.pokemons;
  $PokeTypesTable get pokeTypes => attachedDatabase.pokeTypes;
  $PokemonTypesTable get pokemonTypes => attachedDatabase.pokemonTypes;
  $TriviaResultsTable get triviaResults => attachedDatabase.triviaResults;
  $TriviaAnswersTable get triviaAnswers => attachedDatabase.triviaAnswers;
  $TriviaAchievementsTable get triviaAchievements =>
      attachedDatabase.triviaAchievements;
  TriviaDaoManager get managers => TriviaDaoManager(this);
}

class TriviaDaoManager {
  final _$TriviaDaoMixin _db;
  TriviaDaoManager(this._db);
  $$PokemonsTableTableManager get pokemons =>
      $$PokemonsTableTableManager(_db.attachedDatabase, _db.pokemons);
  $$PokeTypesTableTableManager get pokeTypes =>
      $$PokeTypesTableTableManager(_db.attachedDatabase, _db.pokeTypes);
  $$PokemonTypesTableTableManager get pokemonTypes =>
      $$PokemonTypesTableTableManager(_db.attachedDatabase, _db.pokemonTypes);
  $$TriviaResultsTableTableManager get triviaResults =>
      $$TriviaResultsTableTableManager(_db.attachedDatabase, _db.triviaResults);
  $$TriviaAnswersTableTableManager get triviaAnswers =>
      $$TriviaAnswersTableTableManager(_db.attachedDatabase, _db.triviaAnswers);
  $$TriviaAchievementsTableTableManager get triviaAchievements =>
      $$TriviaAchievementsTableTableManager(
        _db.attachedDatabase,
        _db.triviaAchievements,
      );
}
