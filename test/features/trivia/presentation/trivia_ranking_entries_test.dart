import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_ranking_item.dart';
import 'package:pokedex/features/trivia/presentation/mappers/trivia_view_mapper.dart';

void main() {
  final now = DateTime(2026, 11, 25, 12, 0);

  test('solo la partida más reciente y reciente lleva NUEVO', () {
    final items = [
      TriviaRankingItem(
        score: 900,
        correctCount: 9,
        totalQuestions: 10,
        playedAt: DateTime(2026, 11, 25, 11, 0),
      ),
      TriviaRankingItem(
        score: 400,
        correctCount: 5,
        totalQuestions: 10,
        playedAt: DateTime(2026, 11, 25, 11, 58),
      ),
    ];

    final entries = rankingEntries(items, now: now);

    expect(entries[0].isNew, isFalse);
    expect(entries[1].isNew, isTrue);
  });

  test('si la última partida es antigua, ninguna es NUEVO', () {
    final items = [
      TriviaRankingItem(
        score: 700,
        correctCount: 7,
        totalQuestions: 10,
        playedAt: DateTime(2026, 11, 25, 11, 50),
      ),
    ];

    final entries = rankingEntries(items, now: now);

    expect(entries.single.isNew, isFalse);
  });

  test('justo en el límite de 5 minutos todavía es NUEVO', () {
    final items = [
      TriviaRankingItem(
        score: 700,
        correctCount: 7,
        totalQuestions: 10,
        playedAt: DateTime(2026, 11, 25, 11, 55),
      ),
    ];

    final entries = rankingEntries(items, now: now);

    expect(entries.single.isNew, isTrue);
  });

  test('un ranking vacío no da filas', () {
    expect(rankingEntries(const [], now: now), isEmpty);
  });
}
