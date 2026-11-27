import 'package:equatable/equatable.dart';

/// Lo que pasó en una pregunta de una partida.
class TriviaAnswerRecord extends Equatable {
  const TriviaAnswerRecord({
    required this.pokemonId,
    required this.correct,
    required this.millisecondsUsed,
    required this.hintsUsed,
    required this.points,
  });

  final int pokemonId;
  final bool correct;

  /// Tiempo que tardó en responder (o el límite completo si se agotó).
  final int millisecondsUsed;
  final int hintsUsed;
  final int points;

  @override
  List<Object?> get props => [
    pokemonId,
    correct,
    millisecondsUsed,
    hintsUsed,
    points,
  ];
}

/// Una partida terminada: sus respuestas y los totales que se derivan de ellas.
class TriviaGameResult extends Equatable {
  const TriviaGameResult({required this.answers});

  final List<TriviaAnswerRecord> answers;

  int get score {
    var total = 0;
    for (final answer in answers) {
      total += answer.points;
    }
    return total;
  }

  int get correctCount {
    var total = 0;
    for (final answer in answers) {
      if (answer.correct) {
        total++;
      }
    }
    return total;
  }

  int get hintsUsed {
    var total = 0;
    for (final answer in answers) {
      total += answer.hintsUsed;
    }
    return total;
  }

  @override
  List<Object?> get props => [answers];
}
