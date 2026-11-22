/// Reglas de la trivia (RF-TRV-02, RF-TRV-04, RF-TRV-05). Todos los números
/// están aquí, en un solo lugar, para poder documentarlos en el ADR.
abstract final class TriviaRules {
  static const int questionsPerGame = 10;
  static const int secondsPerQuestion = 15;

  /// Pokémon guardados en el teléfono para poder jugar (RF-TRV-05).
  static const int minPokemonToPlay = 20;

  static const int basePoints = 100;
  static const int maxSpeedBonus = 50;
  static const int hintPenalty = 20;
  static const int maxHintsPerQuestion = 3;

  // Umbrales de los logros.
  static const int lightningSeconds = 3;
  static const int streakTarget = 5;
  static const int expertScore = 1000;
  static const int noHintsMinCorrect = 7;
  static const int trainerCorrectTarget = 50;
  static const int collectorGamesTarget = 25;
}
