import 'package:equatable/equatable.dart';

/// Una fila del ranking local: una partida ya jugada.
class TriviaRankingItem extends Equatable {
  const TriviaRankingItem({
    required this.score,
    required this.correctCount,
    required this.totalQuestions,
    required this.playedAt,
  });

  final int score;
  final int correctCount;
  final int totalQuestions;
  final DateTime playedAt;

  @override
  List<Object?> get props => [score, correctCount, totalQuestions, playedAt];
}
