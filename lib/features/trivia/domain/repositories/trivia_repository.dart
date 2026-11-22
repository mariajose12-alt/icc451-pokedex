import 'package:pokedex/features/trivia/domain/entities/trivia_achievement.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_game_result.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_question.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_ranking_item.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_stats.dart';

/// Lo que la trivia necesita de los datos. Dominio puro: no sabe de Drift.
abstract class TriviaRepository {
  /// Cuántos Pokémon hay en el catálogo local (para el estado "sin datos").
  Stream<int> watchAvailablePokemonCount();

  /// Las preguntas de una partida. Lista vacía si no hay Pokémon suficientes.
  Future<List<TriviaQuestion>> pickQuestions();

  /// Guarda la partida y devuelve los logros que se desbloquearon con ella.
  Future<List<TriviaAchievementId>> saveGame(TriviaGameResult game);

  Stream<TriviaStats> watchStats();

  Stream<List<TriviaRankingItem>> watchRanking({int limit = 10});

  Stream<List<TriviaAchievementProgress>> watchAchievements();
}
