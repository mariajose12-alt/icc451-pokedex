import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_achievement.dart';
import 'package:pokedex/features/trivia/presentation/cubit/trivia_game_cubit.dart';
import 'package:pokedex/features/trivia/presentation/cubit/trivia_game_state.dart';

import '../../../helpers/fake_trivia_repository.dart';

void main() {
  late FakeTriviaRepository repository;
  late TriviaGameCubit cubit;

  Future<void> startGame({int questions = 2, int bestScore = 0}) async {
    repository = FakeTriviaRepository(
      questions: sampleQuestions(questions),
      bestScore: bestScore,
    );

    cubit = TriviaGameCubit(repository: repository, imageGrace: Duration.zero);
    await cubit.start();
  }

  tearDown(() async => cubit.close());

  test('sin Pokémon suficientes muestra el estado sin datos', () async {
    repository = FakeTriviaRepository();
    cubit = TriviaGameCubit(repository: repository, imageGrace: Duration.zero);

    await cubit.start();

    expect(cubit.state, isA<TriviaGameNotEnoughData>());
  });

  test('empieza en la primera pregunta con 15 s', () async {
    await startGame();

    final state = cubit.state as TriviaGameQuestion;
    expect(state.index, 0);
    expect(state.millisecondsLeft, 15000);
    expect(state.hintsUsed, 0);
  });

  test('acierto escribiendo con mayúsculas y espacios', () async {
    await startGame();

    cubit.submitAnswer('  PIKACHU ');

    final state = cubit.state as TriviaGameRevealed;
    expect(state.outcome, TriviaOutcome.correct);
    expect(state.points.total, greaterThan(100));
    expect(state.streak, 1);
  });

  test('fallo: 0 puntos y reinicia la racha', () async {
    await startGame(questions: 3);
    cubit.submitAnswer('pikachu');
    await cubit.next();

    cubit.submitAnswer('raichu');

    final state = cubit.state as TriviaGameRevealed;
    expect(state.outcome, TriviaOutcome.wrong);
    expect(state.points.total, 0);
    expect(state.streak, 0);
  });

  test('cada pista revela una letra y resta 20 puntos', () async {
    await startGame();

    cubit.useHint();
    cubit.useHint();

    final question = cubit.state as TriviaGameQuestion;
    expect(question.hintsUsed, 2);
    expect(question.revealedLetters, 'pi');

    cubit.submitAnswer('pikachu');
    final revealed = cubit.state as TriviaGameRevealed;
    expect(revealed.points.hintPenalty, 40);
  });

  test('no permite más de 3 pistas', () async {
    await startGame();

    for (var i = 0; i < 5; i++) {
      cubit.useHint();
    }

    expect((cubit.state as TriviaGameQuestion).hintsUsed, 3);
  });

  test('saltar cuenta como fallo', () async {
    await startGame();

    cubit.skip();

    final state = cubit.state as TriviaGameRevealed;
    expect(state.outcome, TriviaOutcome.skipped);
    expect(state.points.total, 0);
  });

  test('al agotarse el tiempo revela y da 0 puntos', () {
    fakeAsync((async) {
      repository = FakeTriviaRepository(questions: sampleQuestions(2));
      cubit = TriviaGameCubit(
        repository: repository,
        imageGrace: Duration.zero,
      );
      cubit.start();
      async.flushMicrotasks();

      async.elapse(const Duration(seconds: 14));
      expect(cubit.state, isA<TriviaGameQuestion>());

      async.elapse(const Duration(seconds: 2));
      final state = cubit.state as TriviaGameRevealed;
      expect(state.outcome, TriviaOutcome.timeUp);
      expect(state.points.total, 0);
    });
  });

  test('responder rápido da más puntos que responder tarde', () {
    fakeAsync((async) {
      repository = FakeTriviaRepository(questions: sampleQuestions(2));
      cubit = TriviaGameCubit(
        repository: repository,
        imageGrace: Duration.zero,
      );
      cubit.start();
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 1));
      cubit.submitAnswer('pikachu');
      final fast = (cubit.state as TriviaGameRevealed).points.total;

      cubit.next();
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 12));
      cubit.submitAnswer('pikachu');
      final slow = (cubit.state as TriviaGameRevealed).points.total;

      expect(fast, greaterThan(slow));
    });
  });

  test('la última pregunta guarda la partida y termina', () async {
    await startGame(bestScore: 100);
    cubit.submitAnswer('pikachu');
    await cubit.next();
    cubit.submitAnswer('pikachu');

    expect((cubit.state as TriviaGameRevealed).isLast, isTrue);
    await cubit.next();

    final state = cubit.state as TriviaGameFinished;
    expect(state.result.answers, hasLength(2));
    expect(repository.saved, state.result);
    expect(state.newAchievements, [TriviaAchievementId.firstGame]);
    expect(state.isNewBest, isTrue);
  });

  test('no hay récord si no supera el mejor puntaje', () async {
    await startGame(bestScore: 99999);
    cubit.skip();
    await cubit.next();
    cubit.skip();
    await cubit.next();

    expect((cubit.state as TriviaGameFinished).isNewBest, isFalse);
  });

  test('ignora respuestas fuera de la pregunta en curso', () async {
    await startGame();
    cubit.skip();
    final revealed = cubit.state;

    cubit.submitAnswer('pikachu');
    cubit.useHint();

    expect(cubit.state, revealed);
  });

  test('el reloj no corre hasta que la silueta esté lista', () {
    fakeAsync((async) {
      repository = FakeTriviaRepository(questions: sampleQuestions(2));
      // Gracia larga: solo arranca con imageReady().
      cubit = TriviaGameCubit(
        repository: repository,
        imageGrace: const Duration(seconds: 30),
      );
      cubit.start();
      async.flushMicrotasks();

      async.elapse(const Duration(seconds: 5));
      expect((cubit.state as TriviaGameQuestion).millisecondsLeft, 15000);

      cubit.imageReady();
      async.elapse(const Duration(seconds: 3));
      expect(
        (cubit.state as TriviaGameQuestion).millisecondsLeft,
        lessThan(15000),
      );
    });
  });

  test('si la imagen no responde, el reloj arranca tras la gracia', () {
    fakeAsync((async) {
      repository = FakeTriviaRepository(questions: sampleQuestions(2));
      cubit = TriviaGameCubit(
        repository: repository,
        imageGrace: const Duration(seconds: 5),
      );
      cubit.start();
      async.flushMicrotasks();

      async.elapse(const Duration(seconds: 8));

      // 5 s de espera + 3 s ya corridos.
      expect(
        (cubit.state as TriviaGameQuestion).millisecondsLeft,
        lessThan(15000),
      );
    });
  });

  test('pause detiene el reloj y resume lo reanuda sin perder tiempo', () {
    fakeAsync((async) {
      repository = FakeTriviaRepository(questions: sampleQuestions(2));
      cubit = TriviaGameCubit(
        repository: repository,
        imageGrace: Duration.zero,
      );
      cubit.start();
      async.flushMicrotasks();

      async.elapse(const Duration(seconds: 3));
      cubit.pause();
      final left = (cubit.state as TriviaGameQuestion).millisecondsLeft;

      // En pausa el tiempo no baja, aunque pasen 10 s.
      async.elapse(const Duration(seconds: 10));
      expect((cubit.state as TriviaGameQuestion).millisecondsLeft, left);

      // Al reanudar sigue desde donde estaba.
      cubit.resume();
      async.elapse(const Duration(seconds: 2));
      expect(
        (cubit.state as TriviaGameQuestion).millisecondsLeft,
        lessThan(left),
      );
    });
  });
}
