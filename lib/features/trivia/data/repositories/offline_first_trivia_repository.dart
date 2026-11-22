import 'package:pokedex/features/trivia/data/datasources/local/trivia_local_datasource.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_achievement.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_game_result.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_question.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_ranking_item.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_rules.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_stats.dart';
import 'package:pokedex/features/trivia/domain/repositories/trivia_repository.dart';
import 'package:pokedex/features/trivia/domain/usecases/compute_trivia_stats.dart';
import 'package:pokedex/features/trivia/domain/usecases/evaluate_achievements.dart';

/// La trivia funciona 100 % con la base local: jugar no necesita internet.
class OfflineFirstTriviaRepository implements TriviaRepository {
  OfflineFirstTriviaRepository({required this._local, DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final TriviaLocalDataSource _local;

  // El reloj se puede cambiar en las pruebas para tener fechas fijas.
  final DateTime Function() _now;

  @override
  Stream<int> watchAvailablePokemonCount() => _local.watchPokemonCount();

  @override
  Future<List<TriviaQuestion>> pickQuestions() async {
    final available = await _local.watchPokemonCount().first;
    if (available < TriviaRules.minPokemonToPlay) {
      return const [];
    }
    return _local.randomQuestions(TriviaRules.questionsPerGame);
  }

  @override
  Future<List<TriviaAchievementId>> saveGame(TriviaGameResult game) async {
    // Estadísticas como quedarían CON esta partida, para evaluar los logros.
    final history = await _local.loadGames();
    final stats = computeTriviaStats([...history, game]);
    final alreadyUnlocked = await _local.loadUnlocked();

    final unlocked = evaluateAchievements(
      stats: stats,
      game: game,
      alreadyUnlocked: alreadyUnlocked,
    );

    // Partida y logros nuevos se guardan juntos (una transacción).
    await _local.saveGame(game, playedAt: _now(), unlocked: unlocked);
    return unlocked;
  }

  @override
  Stream<TriviaStats> watchStats() =>
      _local.watchGames().map(computeTriviaStats);

  @override
  Stream<List<TriviaRankingItem>> watchRanking({int limit = 10}) =>
      _local.watchRanking(limit);

  @override
  Stream<List<TriviaAchievementProgress>> watchAchievements() {
    // Cada vez que cambia el historial se recalcula el avance. Los logros se
    // guardan en la misma transacción que la partida, así que nunca se ven
    // desfasados.
    return _local.watchGames().asyncMap((games) async {
      final stats = computeTriviaStats(games);
      final unlocked = await _local.loadUnlocked();
      return [
        for (final id in TriviaAchievementId.values)
          TriviaAchievementProgress(
            id: id,
            unlocked: unlocked.contains(id),
            progress: unlocked.contains(id)
                ? id.target
                : achievementProgress(id, stats),
          ),
      ];
    });
  }
}
