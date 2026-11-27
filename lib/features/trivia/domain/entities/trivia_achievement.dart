import 'package:pokedex/features/trivia/domain/entities/trivia_rules.dart';

/// Los logros de la trivia (RF-TRV-04). El orden de este enum es el orden en
/// que se muestran en la pantalla de Logros.
enum TriviaAchievementId {
  firstGame,
  streak5,
  lightning,
  expert,
  perfect,
  noHints,
  trainer,
  collector;

  /// Cuánto hay que acumular para desbloquearlo (los umbrales documentados).
  int get target {
    switch (this) {
      case TriviaAchievementId.firstGame:
        return 1;
      case TriviaAchievementId.streak5:
        return TriviaRules.streakTarget;
      case TriviaAchievementId.lightning:
        return 1;
      case TriviaAchievementId.expert:
        return TriviaRules.expertScore;
      case TriviaAchievementId.perfect:
        return TriviaRules.questionsPerGame;
      case TriviaAchievementId.noHints:
        return 1;
      case TriviaAchievementId.trainer:
        return TriviaRules.trainerCorrectTarget;
      case TriviaAchievementId.collector:
        return TriviaRules.collectorGamesTarget;
    }
  }
}

/// Un logro con su avance actual, listo para mostrar.
class TriviaAchievementProgress {
  const TriviaAchievementProgress({
    required this.id,
    required this.unlocked,
    required this.progress,
  });

  final TriviaAchievementId id;
  final bool unlocked;

  /// Avance actual (se muestra como progress/target).
  final int progress;

  int get target => id.target;
}
