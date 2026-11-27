import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_achievement.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_question.dart';
import 'package:pokedex/features/trivia/domain/usecases/calculate_question_score.dart';
import 'package:pokedex/features/trivia/presentation/cubit/trivia_game_state.dart';
import 'package:pokedex/features/trivia/presentation/mappers/trivia_view_mapper.dart';
import 'package:pokedex/features/trivia/presentation/widgets/trivia_parts.dart';
import 'package:pokedex/l10n/app_localizations.dart';

const _question = TriviaQuestion(
  pokemonId: 122,
  name: 'mr-mime',
  nationalDexNumber: 122,
  typeNames: ['psychic', 'fairy'],
);

void main() {
  test('las casillas cuentan solo letras y números', () {
    const state = TriviaGameQuestion(
      question: _question,
      index: 2,
      total: 10,
      millisecondsLeft: 9400,
      hintsUsed: 1,
      revealedLetters: 'm',
      score: 240,
      streak: 2,
    );

    final data = questionData(state);

    expect(data.nameLength, 6); // mrmime
    expect(data.questionNumber, 3);
    expect(data.secondsLeft, 10); // 9,4 s se muestra como 10
    expect(data.revealedLetters, 'm');
  });

  test('la revelación marca respondidas, actual y pendientes', () {
    final state = TriviaGameRevealed(
      question: _question,
      index: 2,
      total: 5,
      outcome: TriviaOutcome.wrong,
      points: QuestionScore.zero,
      score: 200,
      streak: 0,
      history: const [true, false, false],
      millisecondsUsed: 7400,
      streakLost: 1,
    );

    final data = revealData(state);

    expect(data.dots, [
      AnswerDotState.correct,
      AnswerDotState.wrong,
      AnswerDotState.current,
      AnswerDotState.pending,
      AnswerDotState.pending,
    ]);
    expect(data.secondsUsed, 7);
    expect(data.streakLost, 1);
    expect(data.pointsEarned, 0);
  });

  testWidgets('el avance de un logro no pasa de su objetivo', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context)!;
            return const SizedBox();
          },
        ),
      ),
    );

    final data = achievementData(const [
      TriviaAchievementProgress(
        id: TriviaAchievementId.expert,
        unlocked: true,
        progress: 1240,
      ),
    ], l10n);

    expect(data.single.progress, 1000);
    expect(data.single.target, 1000);
    expect(data.single.name, isNotEmpty);
  });

  test('la pregunta informa las pistas usadas y lo que restan', () {
    const state = TriviaGameQuestion(
      question: _question,
      index: 0,
      total: 10,
      millisecondsLeft: 12000,
      hintsUsed: 2,
      revealedLetters: 'mr',
      score: 0,
      streak: 0,
    );

    final data = questionData(state);

    expect(data.hintsUsed, 2);
    expect(data.maxHints, 3);
    expect(data.hintPenalty, 40);
  });

  test('la revelación separa acierto, rapidez y pistas', () {
    final state = TriviaGameRevealed(
      question: _question,
      index: 0,
      total: 5,
      outcome: TriviaOutcome.correct,
      points: const QuestionScore(base: 100, speedBonus: 30, hintPenalty: 40),
      score: 90,
      streak: 1,
      history: const [true],
      millisecondsUsed: 6000,
      streakLost: 0,
    );

    final data = revealData(state);

    expect(data.pointsEarned, 90);
    expect(data.basePoints, 100);
    expect(data.speedBonus, 30);
    expect(data.hintCount, 2);
    expect(data.hintPenalty, 40);
  });
}
