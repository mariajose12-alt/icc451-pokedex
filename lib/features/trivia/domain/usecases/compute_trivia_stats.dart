import 'dart:math';

import 'package:pokedex/features/trivia/domain/entities/trivia_game_result.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_stats.dart';

/// Calcula el resumen con todas las partidas, de la más vieja a la más nueva.
/// La racha sigue de una partida a la siguiente: cualquier fallo la reinicia.
TriviaStats computeTriviaStats(List<TriviaGameResult> games) {
  var bestScore = 0;
  var totalCorrect = 0;
  var bestGameCorrect = 0;
  var streak = 0;
  var bestStreak = 0;

  for (final game in games) {
    bestScore = max(bestScore, game.score);
    totalCorrect += game.correctCount;
    bestGameCorrect = max(bestGameCorrect, game.correctCount);

    for (final answer in game.answers) {
      if (answer.correct) {
        streak++;
        bestStreak = max(bestStreak, streak);
      } else {
        streak = 0;
      }
    }
  }

  return TriviaStats(
    gamesPlayed: games.length,
    bestScore: bestScore,
    totalCorrect: totalCorrect,
    currentStreak: streak,
    bestStreak: bestStreak,
    bestGameCorrect: bestGameCorrect,
  );
}
