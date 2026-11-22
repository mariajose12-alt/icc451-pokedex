import 'package:pokedex/features/trivia/domain/entities/trivia_achievement.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_game_result.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_question.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_ranking_item.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_stats.dart';
import 'package:pokedex/features/trivia/domain/repositories/trivia_repository.dart';

class FakeTriviaRepository implements TriviaRepository {
  FakeTriviaRepository({
    this.questions = const [],
    this.bestScore = 0,
    this.achievements = const [],
  });

  final List<TriviaQuestion> questions;
  final int bestScore;
  TriviaGameResult? saved;
  final List<TriviaAchievementProgress> achievements;

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
  Stream<List<TriviaAchievementProgress>> watchAchievements() =>
      Stream.value(achievements);

  @override
  Stream<List<TriviaRankingItem>> watchRanking({int limit = 10}) =>
      Stream.value(const []);
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
