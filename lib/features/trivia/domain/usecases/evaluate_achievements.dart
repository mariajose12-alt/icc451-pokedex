import 'package:pokedex/features/trivia/domain/entities/trivia_achievement.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_game_result.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_rules.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_stats.dart';

/// Avance de un logro acumulable, calculado con el historial.
/// Los logros "de un solo evento" (Relámpago, Sin pistas) no tienen avance
/// parcial: valen 0 hasta que se desbloquean.
int achievementProgress(TriviaAchievementId id, TriviaStats stats) {
  switch (id) {
    case TriviaAchievementId.firstGame:
      return stats.gamesPlayed;
    case TriviaAchievementId.streak5:
      return stats.bestStreak;
    case TriviaAchievementId.expert:
      return stats.bestScore;
    case TriviaAchievementId.perfect:
      return stats.bestGameCorrect;
    case TriviaAchievementId.trainer:
      return stats.totalCorrect;
    case TriviaAchievementId.collector:
      return stats.gamesPlayed;
    case TriviaAchievementId.lightning:
    case TriviaAchievementId.noHints:
      return 0;
  }
}

/// ¿La partida recién jugada cumple el logro "Relámpago"?
bool _hadLightningAnswer(TriviaGameResult game) {
  const limit = TriviaRules.lightningSeconds * 1000;
  for (final answer in game.answers) {
    if (answer.correct && answer.millisecondsUsed < limit) {
      return true;
    }
  }
  return false;
}

/// Devuelve los logros que se desbloquean AHORA: los que cumplen su umbral y
/// todavía no estaban desbloqueados.
///
/// [stats] debe incluir ya la partida que acaba de terminar.
List<TriviaAchievementId> evaluateAchievements({
  required TriviaStats stats,
  required TriviaGameResult game,
  required Set<TriviaAchievementId> alreadyUnlocked,
}) {
  final newlyUnlocked = <TriviaAchievementId>[];

  for (final id in TriviaAchievementId.values) {
    if (alreadyUnlocked.contains(id)) {
      continue;
    }

    final bool reached;
    if (id == TriviaAchievementId.lightning) {
      reached = _hadLightningAnswer(game);
    } else if (id == TriviaAchievementId.noHints) {
      reached =
          game.hintsUsed == 0 &&
          game.correctCount >= TriviaRules.noHintsMinCorrect;
    } else {
      reached = achievementProgress(id, stats) >= id.target;
    }

    if (reached) {
      newlyUnlocked.add(id);
    }
  }

  return newlyUnlocked;
}
