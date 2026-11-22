import 'package:equatable/equatable.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_achievement.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_game_result.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_question.dart';
import 'package:pokedex/features/trivia/domain/usecases/calculate_question_score.dart';

/// Cómo terminó una pregunta.
enum TriviaOutcome { correct, wrong, skipped, timeUp }

sealed class TriviaGameState extends Equatable {
  const TriviaGameState();

  @override
  List<Object?> get props => [];
}

/// Buscando las preguntas en la base.
class TriviaGameLoading extends TriviaGameState {
  const TriviaGameLoading();
}

/// Hay menos Pokémon guardados de los necesarios (PA-11, PA-15).
class TriviaGameNotEnoughData extends TriviaGameState {
  const TriviaGameNotEnoughData({required this.available});

  final int available;

  @override
  List<Object?> get props => [available];
}

/// Una pregunta en curso, con el reloj corriendo.
class TriviaGameQuestion extends TriviaGameState {
  const TriviaGameQuestion({
    required this.question,
    required this.index,
    required this.total,
    required this.millisecondsLeft,
    required this.hintsUsed,
    required this.revealedLetters,
    required this.score,
    required this.streak,
  });

  final TriviaQuestion question;

  /// Empieza en 0. La UI muestra index + 1.
  final int index;
  final int total;
  final int millisecondsLeft;
  final int hintsUsed;

  /// Primeras letras del nombre que las pistas ya mostraron.
  final String revealedLetters;

  /// Puntos acumulados hasta antes de esta pregunta.
  final int score;
  final int streak;

  TriviaGameQuestion copyWith({
    int? millisecondsLeft,
    int? hintsUsed,
    String? revealedLetters,
  }) {
    return TriviaGameQuestion(
      question: question,
      index: index,
      total: total,
      millisecondsLeft: millisecondsLeft ?? this.millisecondsLeft,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      revealedLetters: revealedLetters ?? this.revealedLetters,
      score: score,
      streak: streak,
    );
  }

  @override
  List<Object?> get props => [
    question,
    index,
    total,
    millisecondsLeft,
    hintsUsed,
    revealedLetters,
    score,
    streak,
  ];
}

/// El resultado de la pregunta: la respuesta correcta y cuántos puntos dio.
class TriviaGameRevealed extends TriviaGameState {
  const TriviaGameRevealed({
    required this.question,
    required this.index,
    required this.total,
    required this.outcome,
    required this.points,
    required this.score,
    required this.streak,
    required this.history,
    required this.millisecondsUsed,
    required this.streakLost,
  });

  final TriviaQuestion question;
  final int index;
  final int total;
  final TriviaOutcome outcome;

  /// Desglose (base, bonus, penalización). Vale cero si no acertó.
  final QuestionScore points;

  /// Puntos acumulados YA con esta pregunta.
  final int score;
  final int streak;

  /// Si cada pregunta hasta esta (incluida) fue acierto. Para los puntos de progreso.
  final List<bool> history;
  final int millisecondsUsed;

  /// Racha que se perdió con esta pregunta (0 si acertó).
  final int streakLost;

  bool get isLast => index + 1 >= total;

  @override
  List<Object?> get props => [
    question,
    index,
    total,
    outcome,
    points,
    score,
    streak,
    history,
    millisecondsUsed,
    streakLost,
  ];
}

/// Fin de la partida: ya está guardada en la base.
class TriviaGameFinished extends TriviaGameState {
  const TriviaGameFinished({
    required this.result,
    required this.newAchievements,
    required this.isNewBest,
  });

  final TriviaGameResult result;
  final List<TriviaAchievementId> newAchievements;

  /// ¿Superó su mejor puntaje anterior? (Con puntaje anterior 0 también.)
  final bool isNewBest;

  @override
  List<Object?> get props => [result, newAchievements, isNewBest];
}
