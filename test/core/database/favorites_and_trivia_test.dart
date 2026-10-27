import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db
        .into(db.pokemons)
        .insert(
          PokemonsCompanion.insert(
            id: const Value(25),
            name: 'pikachu',
            nationalDexNumber: 25,
            generationId: 1,
            updatedAt: DateTime(2026, 10, 25),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  test('un Pokémon solo puede ser favorito una vez (PS-06)', () async {
    await db
        .into(db.favorites)
        .insert(FavoritesCompanion.insert(pokemonId: const Value(25)));

    await expectLater(
      db
          .into(db.favorites)
          .insert(FavoritesCompanion.insert(pokemonId: const Value(25))),
      throwsA(anything),
    );
  });

  test('no se puede marcar como favorito un Pokémon inexistente', () async {
    await expectLater(
      db
          .into(db.favorites)
          .insert(FavoritesCompanion.insert(pokemonId: const Value(999))),
      throwsA(anything),
    );
  });

  test('borrar una partida borra sus respuestas (cascada)', () async {
    final partidaId = await db
        .into(db.triviaResults)
        .insert(
          TriviaResultsCompanion.insert(
            score: 100,
            correctAnswers: 1,
            playedAt: DateTime(2026, 10, 26),
          ),
        );

    await db
        .into(db.triviaAnswers)
        .insert(
          TriviaAnswersCompanion.insert(
            triviaResultId: partidaId,
            pokemonId: 25,
            correct: true,
          ),
        );

    await (db.delete(
      db.triviaResults,
    )..where((t) => t.id.equals(partidaId))).go();

    final respuestas = await db.select(db.triviaAnswers).get();

    expect(respuestas, isEmpty);
  });
}
