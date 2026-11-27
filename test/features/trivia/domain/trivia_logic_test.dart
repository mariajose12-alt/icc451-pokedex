import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_achievement.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_game_result.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_stats.dart';
import 'package:pokedex/features/trivia/domain/usecases/calculate_question_score.dart';
import 'package:pokedex/features/trivia/domain/usecases/evaluate_achievements.dart';
import 'package:pokedex/features/trivia/domain/usecases/normalize_answer.dart';

TriviaAnswerRecord answer({
  bool correct = true,
  int ms = 8000,
  int hints = 0,
  int points = 100,
}) {
  return TriviaAnswerRecord(
    pokemonId: 1,
    correct: correct,
    millisecondsUsed: ms,
    hintsUsed: hints,
    points: points,
  );
}

void main() {
  group('comparar el nombre (RF-TRV-01)', () {
    test('ignora mayúsculas, acentos, espacios y signos', () {
      expect(
        isCorrectAnswer(typed: 'Mr. Mime', pokemonName: 'mr-mime'),
        isTrue,
      );
      expect(
        isCorrectAnswer(typed: "FARFETCH'D", pokemonName: 'farfetchd'),
        isTrue,
      );
      expect(isCorrectAnswer(typed: 'Pikáchu', pokemonName: 'pikachu'), isTrue);
    });

    test('un nombre distinto o vacío es incorrecto', () {
      expect(isCorrectAnswer(typed: 'Raichu', pokemonName: 'pikachu'), isFalse);
      expect(isCorrectAnswer(typed: '   ', pokemonName: 'pikachu'), isFalse);
    });
  });

  group('pistas', () {
    test('cada pista revela una letra y nunca el nombre completo', () {
      expect(revealedLetters(pokemonName: 'bulbasaur', hintsUsed: 0), '');
      expect(revealedLetters(pokemonName: 'bulbasaur', hintsUsed: 2), 'bu');
      expect(revealedLetters(pokemonName: 'mew', hintsUsed: 9), 'me');
    });
  });

  group('puntos (RF-TRV-02)', () {
    test('un fallo no suma ni resta', () {
      final score = calculateQuestionScore(
        correct: false,
        millisecondsUsed: 4000,
        hintsUsed: 2,
      );
      expect(score.total, 0);
    });

    test('respuesta instantánea: 100 + 50', () {
      final score = calculateQuestionScore(
        correct: true,
        millisecondsUsed: 0,
        hintsUsed: 0,
      );
      expect(score.base, 100);
      expect(score.speedBonus, 50);
      expect(score.total, 150);
    });

    test('al límite de tiempo no hay bonus', () {
      final score = calculateQuestionScore(
        correct: true,
        millisecondsUsed: 15000,
        hintsUsed: 0,
      );
      expect(score.speedBonus, 0);
      expect(score.total, 100);
    });

    test('cada pista resta 20', () {
      final score = calculateQuestionScore(
        correct: true,
        millisecondsUsed: 15000,
        hintsUsed: 2,
      );
      expect(score.hintPenalty, 40);
      expect(score.total, 60);
    });

    test('el total nunca baja de 0', () {
      final score = calculateQuestionScore(
        correct: true,
        millisecondsUsed: 15000,
        hintsUsed: 9,
      );
      expect(score.total, 0);
    });
  });

  group('logros (RF-TRV-04)', () {
    test('la primera partida desbloquea "Primera partida"', () {
      final game = TriviaGameResult(answers: [answer(points: 100)]);
      final unlocked = evaluateAchievements(
        stats: const TriviaStats(gamesPlayed: 1),
        game: game,
        alreadyUnlocked: const {},
      );
      expect(unlocked, contains(TriviaAchievementId.firstGame));
    });

    test('no repite los que ya estaban desbloqueados', () {
      final game = TriviaGameResult(answers: [answer()]);
      final unlocked = evaluateAchievements(
        stats: const TriviaStats(gamesPlayed: 1),
        game: game,
        alreadyUnlocked: const {TriviaAchievementId.firstGame},
      );
      expect(unlocked, isNot(contains(TriviaAchievementId.firstGame)));
    });

    test('"Relámpago" exige un acierto en menos de 3 s', () {
      final fast = TriviaGameResult(answers: [answer(ms: 2900)]);
      final slow = TriviaGameResult(answers: [answer(ms: 3000)]);
      const stats = TriviaStats(gamesPlayed: 2);

      expect(
        evaluateAchievements(
          stats: stats,
          game: fast,
          alreadyUnlocked: const {},
        ),
        contains(TriviaAchievementId.lightning),
      );
      expect(
        evaluateAchievements(
          stats: stats,
          game: slow,
          alreadyUnlocked: const {},
        ),
        isNot(contains(TriviaAchievementId.lightning)),
      );
    });

    test('"Sin pistas" exige 7 aciertos y cero pistas', () {
      final clean = TriviaGameResult(
        answers: [for (var i = 0; i < 7; i++) answer()],
      );
      final withHint = TriviaGameResult(
        answers: [for (var i = 0; i < 7; i++) answer(hints: i == 0 ? 1 : 0)],
      );
      const stats = TriviaStats(gamesPlayed: 1);

      expect(
        evaluateAchievements(
          stats: stats,
          game: clean,
          alreadyUnlocked: const {},
        ),
        contains(TriviaAchievementId.noHints),
      );
      expect(
        evaluateAchievements(
          stats: stats,
          game: withHint,
          alreadyUnlocked: const {},
        ),
        isNot(contains(TriviaAchievementId.noHints)),
      );
    });

    test('los acumulables usan el historial: racha, récord, perfecto', () {
      final unlocked = evaluateAchievements(
        stats: const TriviaStats(
          gamesPlayed: 3,
          bestScore: 1240,
          totalCorrect: 20,
          bestStreak: 10,
          bestGameCorrect: 10,
        ),
        game: TriviaGameResult(answers: [answer(correct: false, points: 0)]),
        alreadyUnlocked: const {},
      );

      expect(
        unlocked,
        containsAll([
          TriviaAchievementId.streak5,
          TriviaAchievementId.expert,
          TriviaAchievementId.perfect,
        ]),
      );
      expect(unlocked, isNot(contains(TriviaAchievementId.trainer)));
    });
  });
}
