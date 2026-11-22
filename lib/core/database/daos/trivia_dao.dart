import 'package:drift/drift.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/core/database/tables/poke_types_table.dart';
import 'package:pokedex/core/database/tables/pokemon_table.dart';
import 'package:pokedex/core/database/tables/pokemon_types_table.dart';
import 'package:pokedex/core/database/tables/trivia_achievements_table.dart';
import 'package:pokedex/core/database/tables/trivia_answers_table.dart';
import 'package:pokedex/core/database/tables/trivia_results_table.dart';

part 'trivia_dao.g.dart';

/// Una respuesta lista para guardar (sin el id de la partida, que aún no existe).
typedef TriviaAnswerInput = ({
  int pokemonId,
  bool correct,
  int millisecondsUsed,
  int hintsUsed,
  int points,
});

@DriftAccessor(
  tables: [
    Pokemons,
    PokeTypes,
    PokemonTypes,
    TriviaResults,
    TriviaAnswers,
    TriviaAchievements,
  ],
)
class TriviaDao extends DatabaseAccessor<AppDatabase> with _$TriviaDaoMixin {
  TriviaDao(super.db);

  // ---------- Catálogo (solo lectura) ----------

  /// Cuántos Pokémon hay guardados. Si son pocos, no se puede jugar.
  Stream<int> watchPokemonCount() {
    final total = pokemons.id.count();
    return (selectOnly(
      pokemons,
    )..addColumns([total])).map((row) => row.read(total) ?? 0).watchSingle();
  }

  /// [count] Pokémon al azar. SQLite hace el sorteo (ORDER BY RANDOM()).
  Future<List<PokemonEntry>> randomPokemon(int count) {
    return (select(pokemons)
          ..orderBy([(_) => OrderingTerm.random()])
          ..limit(count))
        .get();
  }

  /// Nombres de tipo de cada Pokémon, en orden de slot (tipo 1, tipo 2).
  Future<Map<int, List<String>>> typeNamesOf(List<int> pokemonIds) async {
    final query =
        select(pokemonTypes).join([
            innerJoin(pokeTypes, pokeTypes.id.equalsExp(pokemonTypes.typeId)),
          ])
          ..where(pokemonTypes.pokemonId.isIn(pokemonIds))
          ..orderBy([OrderingTerm.asc(pokemonTypes.slot)]);

    final result = <int, List<String>>{};
    for (final row in await query.get()) {
      final pokemonId = row.readTable(pokemonTypes).pokemonId;
      final typeName = row.readTable(pokeTypes).name;
      result.putIfAbsent(pokemonId, () => []).add(typeName);
    }
    return result;
  }

  // ---------- Datos del usuario ----------

  /// Guarda la partida COMPLETA (resultado + respuestas + logros nuevos) en
  /// una sola transacción: o se guarda todo o no se guarda nada.
  Future<void> saveGame({
    required int score,
    required int correctAnswers,
    required int totalQuestions,
    required int hintsUsed,
    required DateTime playedAt,
    required List<TriviaAnswerInput> answers,
    required List<String> unlockedAchievementIds,
  }) {
    return transaction(() async {
      final resultId = await into(triviaResults).insert(
        TriviaResultsCompanion.insert(
          score: score,
          correctAnswers: correctAnswers,
          playedAt: playedAt,
          totalQuestions: Value(totalQuestions),
          hintsUsed: Value(hintsUsed),
        ),
      );

      for (final answer in answers) {
        await into(triviaAnswers).insert(
          TriviaAnswersCompanion.insert(
            triviaResultId: resultId,
            pokemonId: answer.pokemonId,
            correct: answer.correct,
            millisecondsUsed: Value(answer.millisecondsUsed),
            hintsUsed: Value(answer.hintsUsed),
            points: Value(answer.points),
          ),
        );
      }

      for (final id in unlockedAchievementIds) {
        // insertOrIgnore: si ya estaba desbloqueado, se conserva su fecha.
        await into(triviaAchievements).insert(
          TriviaAchievementsCompanion.insert(id: id, unlockedAt: playedAt),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  /// Todas las respuestas, en el orden en que se guardaron (= cronológico).
  Stream<List<TriviaAnswersEntry>> watchAnswers() {
    return (select(
      triviaAnswers,
    )..orderBy([(t) => OrderingTerm.asc(t.id)])).watch();
  }

  Future<List<TriviaAnswersEntry>> getAnswers() {
    return (select(
      triviaAnswers,
    )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
  }

  /// Mejores partidas: más puntos primero; a igual puntaje, la más reciente.
  Stream<List<TriviaResultEntry>> watchRanking(int limit) {
    return (select(triviaResults)
          ..orderBy([
            (t) => OrderingTerm.desc(t.score),
            (t) => OrderingTerm.desc(t.playedAt),
          ])
          ..limit(limit))
        .watch();
  }

  Future<List<TriviaAchievementEntry>> getUnlocked() {
    return select(triviaAchievements).get();
  }
}
