import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/core/database/daos/trivia_dao.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_achievement.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_game_result.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_question.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_ranking_item.dart';

/// Envuelve el DAO y convierte filas de Drift en entidades de dominio.
class TriviaLocalDataSource {
  const TriviaLocalDataSource({required this._dao});

  final TriviaDao _dao;

  Stream<int> watchPokemonCount() => _dao.watchPokemonCount();

  Future<List<TriviaQuestion>> randomQuestions(int count) async {
    final rows = await _dao.randomPokemon(count);
    final types = await _dao.typeNamesOf([for (final row in rows) row.id]);

    return [
      for (final row in rows)
        TriviaQuestion(
          pokemonId: row.id,
          name: row.name,
          nationalDexNumber: row.nationalDexNumber,
          typeNames: types[row.id] ?? const [],
          artworkUrl: row.artworkUrl,
          spriteUrl: row.spriteUrl,
        ),
    ];
  }

  Stream<List<TriviaGameResult>> watchGames() =>
      _dao.watchAnswers().map(_groupIntoGames);

  Future<List<TriviaGameResult>> loadGames() async =>
      _groupIntoGames(await _dao.getAnswers());

  Future<Set<TriviaAchievementId>> loadUnlocked() async {
    final names = {for (final row in await _dao.getUnlocked()) row.id};
    return {
      for (final id in TriviaAchievementId.values)
        if (names.contains(id.name)) id,
    };
  }

  Stream<List<TriviaRankingItem>> watchRanking(int limit) {
    return _dao.watchRanking(limit).map((rows) {
      return [
        for (final row in rows)
          TriviaRankingItem(
            score: row.score,
            correctCount: row.correctAnswers,
            totalQuestions: row.totalQuestions,
            playedAt: row.playedAt,
          ),
      ];
    });
  }

  Future<void> saveGame(
    TriviaGameResult game, {
    required DateTime playedAt,
    required List<TriviaAchievementId> unlocked,
  }) {
    return _dao.saveGame(
      score: game.score,
      correctAnswers: game.correctCount,
      totalQuestions: game.answers.length,
      hintsUsed: game.hintsUsed,
      playedAt: playedAt,
      answers: [
        for (final answer in game.answers)
          (
            pokemonId: answer.pokemonId,
            correct: answer.correct,
            millisecondsUsed: answer.millisecondsUsed,
            hintsUsed: answer.hintsUsed,
            points: answer.points,
          ),
      ],
      unlockedAchievementIds: [for (final id in unlocked) id.name],
    );
  }

  /// Agrupa las respuestas por partida. Como vienen ordenadas por id, tanto
  /// las partidas como sus respuestas quedan en orden cronológico.
  List<TriviaGameResult> _groupIntoGames(List<TriviaAnswersEntry> rows) {
    final byGame = <int, List<TriviaAnswerRecord>>{};
    for (final row in rows) {
      byGame
          .putIfAbsent(row.triviaResultId, () => [])
          .add(
            TriviaAnswerRecord(
              pokemonId: row.pokemonId,
              correct: row.correct,
              millisecondsUsed: row.millisecondsUsed,
              hintsUsed: row.hintsUsed,
              points: row.points,
            ),
          );
    }
    return [
      for (final answers in byGame.values) TriviaGameResult(answers: answers),
    ];
  }

  /// Todas las preguntas posibles, mezcladas. Un solo viaje a la base para
  /// los tipos (en vez de uno por Pokémon).
  Future<List<TriviaQuestion>> allQuestionsShuffled() async {
    final rows = await _dao.shuffledPokemon();
    final types = await _dao.typeNamesOf([for (final row in rows) row.id]);

    return [
      for (final row in rows)
        TriviaQuestion(
          pokemonId: row.id,
          name: row.name,
          nationalDexNumber: row.nationalDexNumber,
          typeNames: types[row.id] ?? const [],
          artworkUrl: row.artworkUrl,
          spriteUrl: row.spriteUrl,
        ),
    ];
  }
}
