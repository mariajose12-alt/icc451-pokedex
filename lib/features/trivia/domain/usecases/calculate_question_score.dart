import 'package:equatable/equatable.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_rules.dart';

/// Desglose de los puntos de una pregunta (es lo que muestra la revelación).
class QuestionScore extends Equatable {
  const QuestionScore({
    required this.base,
    required this.speedBonus,
    required this.hintPenalty,
  });

  /// Pregunta fallada: no suma ni resta nada.
  static const QuestionScore zero = QuestionScore(
    base: 0,
    speedBonus: 0,
    hintPenalty: 0,
  );

  final int base;
  final int speedBonus;
  final int hintPenalty;

  /// Total de la pregunta. Nunca baja de 0.
  int get total {
    final sum = base + speedBonus - hintPenalty;
    return sum < 0 ? 0 : sum;
  }

  @override
  List<Object?> get props => [base, speedBonus, hintPenalty];
}

/// Calcula los puntos de una pregunta (RF-TRV-02).
///  - Fallo (o saltar, o tiempo agotado): 0 puntos.
///  - Acierto: 100 base + hasta 50 de bonus según el tiempo que sobró
///    − 20 por cada pista usada.
QuestionScore calculateQuestionScore({
  required bool correct,
  required int millisecondsUsed,
  required int hintsUsed,
}) {
  if (!correct) {
    return QuestionScore.zero;
  }

  const totalMs = TriviaRules.secondsPerQuestion * 1000;
  var used = millisecondsUsed;
  if (used < 0) {
    used = 0;
  }
  if (used > totalMs) {
    used = totalMs;
  }

  // Fracción del tiempo que sobró: 1.0 = respondió al instante, 0.0 = al límite.
  final leftover = (totalMs - used) / totalMs;
  final bonus = (TriviaRules.maxSpeedBonus * leftover).round();

  return QuestionScore(
    base: TriviaRules.basePoints,
    speedBonus: bonus,
    hintPenalty: hintsUsed * TriviaRules.hintPenalty,
  );
}
