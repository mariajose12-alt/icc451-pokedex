import 'package:pokedex/features/trivia/domain/entities/trivia_achievement.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_ranking_item.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_rules.dart';
import 'package:pokedex/features/trivia/domain/usecases/normalize_answer.dart';
import 'package:pokedex/features/trivia/presentation/cubit/trivia_game_state.dart';
import 'package:pokedex/features/trivia/presentation/cubit/trivia_home_cubit.dart';
import 'package:pokedex/features/trivia/presentation/models/trivia_view_data.dart';
import 'package:pokedex/features/trivia/presentation/widgets/trivia_parts.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Nombre y descripción de un logro, ya traducidos.
({String name, String description}) achievementTexts(
  AppLocalizations l10n,
  TriviaAchievementId id,
) {
  switch (id) {
    case TriviaAchievementId.firstGame:
      return (
        name: l10n.triviaAchFirstGameName,
        description: l10n.triviaAchFirstGameDesc,
      );
    case TriviaAchievementId.streak5:
      return (
        name: l10n.triviaAchStreak5Name,
        description: l10n.triviaAchStreak5Desc(TriviaRules.streakTarget),
      );
    case TriviaAchievementId.lightning:
      return (
        name: l10n.triviaAchLightningName,
        description: l10n.triviaAchLightningDesc(TriviaRules.lightningSeconds),
      );
    case TriviaAchievementId.expert:
      return (
        name: l10n.triviaAchExpertName,
        description: l10n.triviaAchExpertDesc(TriviaRules.expertScore),
      );
    case TriviaAchievementId.perfect:
      return (
        name: l10n.triviaAchPerfectName,
        description: l10n.triviaAchPerfectDesc(TriviaRules.questionsPerGame),
      );
    case TriviaAchievementId.noHints:
      return (
        name: l10n.triviaAchNoHintsName,
        description: l10n.triviaAchNoHintsDesc(TriviaRules.noHintsMinCorrect),
      );
    case TriviaAchievementId.trainer:
      return (
        name: l10n.triviaAchTrainerName,
        description: l10n.triviaAchTrainerDesc(
          TriviaRules.trainerCorrectTarget,
        ),
      );
    case TriviaAchievementId.collector:
      return (
        name: l10n.triviaAchCollectorName,
        description: l10n.triviaAchCollectorDesc(
          TriviaRules.collectorGamesTarget,
        ),
      );
  }
}

TriviaHomeData homeData(TriviaHomeState state) {
  return TriviaHomeData(
    bestScore: state.stats.bestScore,
    streak: state.stats.currentStreak,
    gamesPlayed: state.stats.gamesPlayed,
    savedPokemon: state.savedPokemon,
    silhouetteUrl: state.silhouetteUrl,
  );
}

TriviaQuestionData questionData(TriviaGameQuestion state) {
  return TriviaQuestionData(
    questionNumber: state.index + 1,
    totalQuestions: state.total,
    score: state.score,
    // Se redondea hacia arriba: con 0,4 s restantes se ve "1".
    secondsLeft: (state.millisecondsLeft / 1000).ceil(),
    totalSeconds: TriviaRules.secondsPerQuestion,
    // Una casilla por letra que hay que escribir (sin guiones ni espacios).
    nameLength: normalizeAnswer(state.question.name).length,
    revealedLetters: state.revealedLetters,
    imageUrl: state.question.imageUrl,
    hintsUsed: state.hintsUsed,
    maxHints: TriviaRules.maxHintsPerQuestion,
    hintPenalty: state.hintsUsed * TriviaRules.hintPenalty,
  );
}

TriviaRevealData revealData(TriviaGameRevealed state) {
  return TriviaRevealData(
    questionNumber: state.index + 1,
    totalQuestions: state.total,
    score: state.score,
    pointsEarned: state.points.total,
    basePoints: state.points.base,
    speedBonus: state.points.speedBonus,
    hintCount: state.points.hintPenalty ~/ TriviaRules.hintPenalty,
    hintPenalty: state.points.hintPenalty,
    secondsUsed: (state.millisecondsUsed / 1000).round(),
    streakLost: state.streakLost,
    pokemonNumber: state.question.nationalDexNumber,
    pokemonName: state.question.name,
    typeNames: state.question.typeNames,
    imageUrl: state.question.imageUrl,
    dots: [
      for (var i = 0; i < state.total; i++)
        if (i < state.index)
          state.history[i] ? AnswerDotState.correct : AnswerDotState.wrong
        else if (i == state.index)
          AnswerDotState.current
        else
          AnswerDotState.pending,
    ],
  );
}

TriviaResultData resultData(TriviaGameFinished state, AppLocalizations l10n) {
  // La pantalla muestra un solo logro. Si se desbloquearon varios, el primero.
  final first = state.newAchievements.isEmpty
      ? null
      : achievementTexts(l10n, state.newAchievements.first);

  return TriviaResultData(
    score: state.result.score,
    correctCount: state.result.correctCount,
    total: state.result.answers.length,
    newRecord: state.isNewBest,
    dots: [
      for (final answer in state.result.answers)
        answer.correct ? AnswerDotState.correct : AnswerDotState.wrong,
    ],
    achievementName: first?.name,
    achievementDescription: first?.description,
  );
}

/// Convierte el ranking en filas para la pantalla. [now] es la hora actual
/// (se recibe para poder probar la insignia sin esperar minutos).
List<TriviaRankingEntry> rankingEntries(
  List<TriviaRankingItem> items, {
  required DateTime now,
}) {
  // La partida más reciente de la lista.
  DateTime? latest;
  for (final item in items) {
    if (latest == null || item.playedAt.isAfter(latest)) {
      latest = item.playedAt;
    }
  }

  return [
    for (final item in items)
      TriviaRankingEntry(
        score: item.score,
        correctCount: item.correctCount,
        total: item.totalQuestions,
        date: item.playedAt,
        // NUEVO: solo la partida más reciente, y solo si se jugó hace poco.
        isNew:
            item.playedAt == latest &&
            now.difference(item.playedAt) <= TriviaRules.newBadgeWindow,
      ),
  ];
}

List<TriviaAchievementData> achievementData(
  List<TriviaAchievementProgress> items,
  AppLocalizations l10n,
) {
  return [
    for (final item in items)
      TriviaAchievementData(
        name: achievementTexts(l10n, item.id).name,
        description: achievementTexts(l10n, item.id).description,
        unlocked: item.unlocked,
        // El avance nunca pasa del objetivo (por ejemplo 1240/1000 → 1000/1000).
        progress: item.progress > item.target ? item.target : item.progress,
        target: item.target,
      ),
  ];
}
