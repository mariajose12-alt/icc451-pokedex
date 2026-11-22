import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/connectivity/service_availability.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/features/trivia/data/datasources/local/trivia_local_datasource.dart';
import 'package:pokedex/features/trivia/data/repositories/offline_first_trivia_repository.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_achievement.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_game_result.dart';

import '../../../helpers/fake_connectivity_monitor.dart';
import '../../../helpers/fake_trivia_image_cache.dart';

void main() {
  late AppDatabase db;
  late OfflineFirstTriviaRepository repository;
  var clock = DateTime(2026, 11, 21, 10);
  late FakeConnectivityMonitor connectivity;
  late FakeTriviaImageCache images;

  setUp(() {
    clock = DateTime(2026, 11, 21, 10);
    db = AppDatabase(NativeDatabase.memory());
    connectivity = FakeConnectivityMonitor(ServiceAvailability.online);
    images = FakeTriviaImageCache();
    repository = OfflineFirstTriviaRepository(
      local: TriviaLocalDataSource(dao: db.triviaDao),
      connectivity: connectivity,
      images: images,
      now: () => clock,
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedPokemon(int count) async {
    for (var id = 1; id <= count; id++) {
      await db
          .into(db.pokemons)
          .insert(
            PokemonsCompanion.insert(
              id: Value(id),
              name: 'pokemon$id',
              nationalDexNumber: id,
              generationId: 1,
              artworkUrl: Value('https://img/$id.png'),
              updatedAt: DateTime(2026, 10, 27),
            ),
          );
    }
  }

  // Partida de 10 preguntas con [correct] aciertos al principio.
  TriviaGameResult game({int correct = 10, int ms = 8000, int hints = 0}) {
    return TriviaGameResult(
      answers: [
        for (var i = 0; i < 10; i++)
          TriviaAnswerRecord(
            pokemonId: i + 1,
            correct: i < correct,
            millisecondsUsed: ms,
            hintsUsed: hints,
            points: i < correct ? 100 : 0,
          ),
      ],
    );
  }

  group('preguntas', () {
    test('no arma partida si hay menos de 20 Pokémon', () async {
      await seedPokemon(19);

      expect(await repository.pickQuestions(), isEmpty);
    });

    test('arma 10 preguntas distintas con 20 o más Pokémon', () async {
      await seedPokemon(25);

      final questions = await repository.pickQuestions();

      expect(questions, hasLength(10));
      expect({for (final q in questions) q.pokemonId}, hasLength(10));
    });

    test('informa cuántos Pokémon hay', () async {
      await seedPokemon(7);

      expect(await repository.watchAvailablePokemonCount().first, 7);
    });
  });

  group('guardar partidas', () {
    setUp(() => seedPokemon(25));

    test('guarda resultado y respuestas', () async {
      await repository.saveGame(game(correct: 6));

      final results = await db.select(db.triviaResults).get();
      final answers = await db.select(db.triviaAnswers).get();

      expect(results.single.score, 600);
      expect(results.single.correctAnswers, 6);
      expect(results.single.totalQuestions, 10);
      expect(answers, hasLength(10));
    });

    test('la primera partida perfecta desbloquea sus logros', () async {
      final unlocked = await repository.saveGame(game());

      expect(
        unlocked,
        unorderedEquals([
          TriviaAchievementId.firstGame,
          TriviaAchievementId.streak5,
          TriviaAchievementId.expert,
          TriviaAchievementId.perfect,
          TriviaAchievementId.noHints,
        ]),
      );
    });

    test('un logro no se desbloquea dos veces y conserva su fecha', () async {
      await repository.saveGame(game(correct: 3));
      final firstDate = clock;

      clock = DateTime(2026, 11, 22);
      final second = await repository.saveGame(game(correct: 3));

      expect(second, isNot(contains(TriviaAchievementId.firstGame)));
      final rows = await db.select(db.triviaAchievements).get();
      final first = rows.firstWhere((r) => r.id == 'firstGame');
      expect(first.unlockedAt, firstDate);
    });

    test('Relámpago: un acierto en menos de 3 s', () async {
      final unlocked = await repository.saveGame(game(correct: 2, ms: 2500));

      expect(unlocked, contains(TriviaAchievementId.lightning));
    });
  });

  group('estadísticas, ranking y logros', () {
    setUp(() => seedPokemon(25));

    test('estadísticas con dos partidas', () async {
      await repository.saveGame(game(correct: 4));
      await repository.saveGame(game(correct: 9));

      final stats = await repository.watchStats().first;

      expect(stats.gamesPlayed, 2);
      expect(stats.bestScore, 900);
      expect(stats.totalCorrect, 13);
      expect(stats.bestGameCorrect, 9);
      // La racha sigue entre partidas: 9 aciertos seguidos (los de la segunda).
      expect(stats.bestStreak, 9);
    });

    test('ranking ordenado por puntaje', () async {
      await repository.saveGame(game(correct: 4));
      await repository.saveGame(game(correct: 9));
      await repository.saveGame(game(correct: 6));

      final ranking = await repository.watchRanking().first;

      expect([for (final r in ranking) r.score], [900, 600, 400]);
    });

    test('el ranking respeta el límite', () async {
      for (var i = 0; i < 4; i++) {
        await repository.saveGame(game(correct: i + 1));
      }

      expect(await repository.watchRanking(limit: 2).first, hasLength(2));
    });

    test('sin partidas: logros bloqueados y en cero', () async {
      final achievements = await repository.watchAchievements().first;

      expect(achievements, hasLength(8));
      expect(achievements.every((a) => !a.unlocked && a.progress == 0), isTrue);
    });

    test('el progreso de Entrenador crece con los aciertos', () async {
      await repository.saveGame(game(correct: 5));
      final achievements = await repository.watchAchievements().first;
      final trainer = achievements.firstWhere(
        (a) => a.id == TriviaAchievementId.trainer,
      );

      expect(trainer.progress, 5);
      expect(trainer.target, 50);
      expect(trainer.unlocked, isFalse);
    });
  });

  test('guardar una partida no modifica el catálogo (OF-21)', () async {
    await seedPokemon(25);

    await repository.saveGame(game());

    expect(await db.select(db.pokemons).get(), hasLength(25));
  });

  test('sin conexión solo se sortean Pokémon con imagen guardada', () async {
    await seedPokemon(30);
    connectivity.emit(ServiceAvailability.offline);
    // Solo 25 de los 30 tienen su imagen guardada.
    images.cached.addAll([for (var i = 1; i <= 25; i++) 'https://img/$i.png']);

    final questions = await repository.pickQuestions();

    expect(questions, hasLength(10));
    expect(questions.every((q) => q.pokemonId <= 25), isTrue);
  });

  test(
    'sin conexión y con menos de 20 imágenes guardadas no se juega',
    () async {
      await seedPokemon(30);
      connectivity.emit(ServiceAvailability.offline);
      images.cached.addAll([
        for (var i = 1; i <= 19; i++) 'https://img/$i.png',
      ]);

      expect(await repository.pickQuestions(), isEmpty);
      expect(await repository.watchAvailablePokemonCount().first, 19);
    },
  );

  test(
    'con conexión se usan todos aunque no haya imágenes guardadas',
    () async {
      await seedPokemon(30);

      expect(await repository.pickQuestions(), hasLength(10));
    },
  );
}
