import 'package:pokedex/features/trivia/presentation/widgets/trivia_parts.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_rules.dart';

/// Datos de cada pantalla de la trivia. Son simples: las pantallas solo los
/// muestran. Más adelante los llenará el motor de la trivia.

class TriviaHomeData {
  const TriviaHomeData({
    required this.bestScore,
    required this.streak,
    required this.gamesPlayed,
    required this.savedPokemon,
    required this.silhouetteUrl,
  });

  final int bestScore;
  final int streak;
  final int gamesPlayed;
  final int savedPokemon;
  final String? silhouetteUrl;
}

class TriviaQuestionData {
  const TriviaQuestionData({
    required this.questionNumber,
    required this.totalQuestions,
    required this.score,
    required this.secondsLeft,
    required this.totalSeconds,
    required this.nameLength,
    required this.revealedLetters,
    required this.imageUrl,
    this.hintsUsed = 0,
    this.maxHints = TriviaRules.maxHintsPerQuestion,
    this.hintPenalty = 0,
  });

  final int questionNumber;
  final int totalQuestions;
  final int score;
  final int secondsLeft;
  final int totalSeconds;

  /// Cuántas letras tiene el nombre (una casilla por letra).
  final int nameLength;
  final String revealedLetters;
  final String? imageUrl;

  /// Pistas usadas, máximo permitido y puntos que restan en esta pregunta.
  final int hintsUsed;
  final int maxHints;
  final int hintPenalty;
}

class TriviaRevealData {
  const TriviaRevealData({
    required this.questionNumber,
    required this.totalQuestions,
    required this.score,
    required this.pointsEarned,
    required this.speedBonus,
    required this.secondsUsed,
    required this.streakLost,
    required this.pokemonNumber,
    required this.pokemonName,
    required this.typeNames,
    required this.imageUrl,
    required this.dots,
    this.basePoints = TriviaRules.basePoints,
    this.hintCount = 0,
    this.hintPenalty = 0,
  });

  final int questionNumber;
  final int totalQuestions;
  final int score;
  final int pointsEarned;
  final int speedBonus;
  final int secondsUsed;

  /// Racha que se perdió (solo cuando no se acertó).
  final int streakLost;
  final int pokemonNumber;
  final String pokemonName;
  final List<String> typeNames;
  final String? imageUrl;
  final List<AnswerDotState> dots;

  /// Puntos base del acierto (sin bonus ni pistas).
  final int basePoints;

  /// Pistas usadas y puntos que restaron.
  final int hintCount;
  final int hintPenalty;
}

class TriviaResultData {
  const TriviaResultData({
    required this.score,
    required this.correctCount,
    required this.total,
    required this.newRecord,
    required this.dots,
    this.achievementName,
    this.achievementDescription,
  });

  final int score;
  final int correctCount;
  final int total;
  final bool newRecord;
  final List<AnswerDotState> dots;

  /// Si la partida desbloqueó un logro.
  final String? achievementName;
  final String? achievementDescription;
}

/// Una partida guardada en el ranking.
class TriviaRankingEntry {
  const TriviaRankingEntry({
    required this.score,
    required this.correctCount,
    required this.total,
    required this.date,
    this.isNew = false,
  });

  final int score;
  final int correctCount;
  final int total;
  final DateTime date;

  /// true si es la partida que se acaba de jugar.
  final bool isNew;
}

/// Un logro. El texto viene en los datos solo mientras no exista el motor;
/// después se buscará por identificador en los .arb.
class TriviaAchievementData {
  const TriviaAchievementData({
    required this.name,
    required this.description,
    required this.unlocked,
    required this.progress,
    required this.target,
  });

  final String name;
  final String description;
  final bool unlocked;
  final int progress;
  final int target;
}

class TriviaNoDataData {
  const TriviaNoDataData({required this.saved, required this.required});

  /// Pokémon guardados ahora.
  final int saved;

  /// Mínimo para poder jugar.
  final int required;
}
