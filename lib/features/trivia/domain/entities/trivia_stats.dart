import 'package:equatable/equatable.dart';

/// Resumen de todo el historial local. Alimenta la pantalla de inicio
/// (mejor puntaje, racha, partidas) y el progreso de los logros.
class TriviaStats extends Equatable {
  const TriviaStats({
    this.gamesPlayed = 0,
    this.bestScore = 0,
    this.totalCorrect = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.bestGameCorrect = 0,
  });

  final int gamesPlayed;
  final int bestScore;
  final int totalCorrect;

  /// Aciertos seguidos al final del historial (se reinicia con un fallo).
  final int currentStreak;

  /// La racha más larga de todo el historial.
  final int bestStreak;

  /// Más aciertos logrados en una sola partida.
  final int bestGameCorrect;

  @override
  List<Object?> get props => [
    gamesPlayed,
    bestScore,
    totalCorrect,
    currentStreak,
    bestStreak,
    bestGameCorrect,
  ];
}
