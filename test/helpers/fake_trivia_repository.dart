import 'package:pokedex/features/trivia/domain/entities/trivia_achievement.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_game_result.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_question.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_ranking_item.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_stats.dart';
import 'package:pokedex/features/trivia/domain/repositories/trivia_repository.dart';

class FakeTriviaRepository implements TriviaRepository {
  FakeTriviaRepository({this.questions = const [], this.bestScore = 0});

  final List<TriviaQuestion> questions;
  final int bestScore;
  TriviaGameResult? saved;

  @override
  Future<List<TriviaQuestion>> pickQuestions() async => questions;

  @override
  Stream<int> watchAvailablePokemonCount() => Stream.value(questions.length);

  @override
  Future<List<TriviaAchievementId>> saveGame(TriviaGameResult game) async {
    saved = game;
    return [TriviaAchievementId.firstGame];
  }

  @override
  Stream<TriviaStats> watchStats() =>
      Stream.value(TriviaStats(bestScore: bestScore));

  @override
  Stream<List<TriviaRankingItem>> watchRanking({int limit = 10}) =>
      const Stream.empty();

  @override
  Stream<List<TriviaAchievementProgress>> watchAchievements() =>
      const Stream.empty();
}

List<TriviaQuestion> sampleQuestions(int count) {
  return [
    for (var i = 1; i <= count; i++)
      TriviaQuestion(
        pokemonId: i,
        name: 'pikachu',
        nationalDexNumber: i,
        typeNames: const ['electric'],
      ),
  ];
}
