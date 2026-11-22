import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_game_result.dart';
import 'package:pokedex/features/trivia/domain/usecases/compute_trivia_stats.dart';

TriviaGameResult game(List<bool> results) {
  return TriviaGameResult(
    answers: [
      for (final ok in results)
        TriviaAnswerRecord(
          pokemonId: 1,
          correct: ok,
          millisecondsUsed: 5000,
          hintsUsed: 0,
          points: ok ? 100 : 0,
        ),
    ],
  );
}

void main() {
  test('sin partidas todo es cero', () {
    final stats = computeTriviaStats(const []);

    expect(stats.gamesPlayed, 0);
    expect(stats.bestStreak, 0);
  });

  test('un fallo reinicia la racha', () {
    final stats = computeTriviaStats([
      game([true, true, true, false, true]),
    ]);

    expect(stats.bestStreak, 3);
    expect(stats.currentStreak, 1);
  });

  test('la racha continúa entre partidas', () {
    final stats = computeTriviaStats([
      game([false, true, true]),
      game([true, true, false]),
    ]);

    expect(stats.bestStreak, 4);
    expect(stats.currentStreak, 0);
  });
}
