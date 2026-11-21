import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/trivia/presentation/models/trivia_view_data.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_achievements_page.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_home_page.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_no_data_page.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_question_page.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_ranking_page.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_result_page.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_reveal_page.dart';
import 'package:pokedex/features/trivia/presentation/preview/trivia_sample_data.dart';
import 'package:pokedex/features/trivia/presentation/widgets/trivia_parts.dart';
import 'package:pokedex/l10n/app_localizations.dart';

void noop() {}

// Sin URL de imagen: los tests no usan la red, se ve el icono de respaldo.
const _home = TriviaHomeData(
  bestScore: 1240,
  streak: 5,
  gamesPlayed: 12,
  savedPokemon: 1025,
  silhouetteUrl: null,
);

const _question = TriviaQuestionData(
  questionNumber: 3,
  totalQuestions: 10,
  score: 240,
  secondsLeft: 9,
  totalSeconds: 15,
  nameLength: 12,
  typedText: 'Bul',
  imageUrl: null,
);

const _reveal = TriviaRevealData(
  questionNumber: 3,
  totalQuestions: 10,
  score: 390,
  pointsEarned: 150,
  speedBonus: 50,
  secondsUsed: 6,
  streakLost: 3,
  pokemonNumber: 1,
  pokemonName: 'bulbasaur',
  typeNames: ['grass', 'poison'],
  imageUrl: null,
  dots: [
    AnswerDotState.correct,
    AnswerDotState.wrong,
    AnswerDotState.current,
    AnswerDotState.pending,
  ],
);

Widget _host(Widget page, {double textScale = 1}) {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: page,
  );
}

void main() {
  final pages = <String, Widget Function()>{
    'inicio': () => const TriviaHomePage(
      data: _home,
      onPlay: noop,
      onRanking: noop,
      onAchievements: noop,
    ),
    'pregunta': () => const TriviaQuestionPage(
      data: _question,
      onGuess: noop,
      onHint: noop,
      onSkip: noop,
    ),
    'acierto': () => const TriviaRevealPage(
      kind: TriviaRevealKind.correct,
      data: _reveal,
      onNext: noop,
    ),
    'tiempo agotado': () => const TriviaRevealPage(
      kind: TriviaRevealKind.timeUp,
      data: _reveal,
      onNext: noop,
    ),
    'resultado': () => TriviaResultPage(
      data: TriviaSampleData.result,
      onPlayAgain: noop,
      onRanking: noop,
      onHome: noop,
    ),
    'ranking': () =>
        TriviaRankingPage(entries: TriviaSampleData.ranking, onBack: noop),
    'ranking vacío': () => const TriviaRankingPage(entries: [], onBack: noop),
    'logros': () => TriviaAchievementsPage(
      achievements: TriviaSampleData.achievements,
      onBack: noop,
    ),
    'datos insuficientes': () => const TriviaNoDataPage(
      data: TriviaNoDataData(saved: 12, required: 20),
      onGoCatalog: noop,
      onRetry: noop,
    ),
  };

  // RNF-ACC: ninguna pantalla debe desbordarse con texto al 200 %
  // en un teléfono pequeño.
  for (final entry in pages.entries) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('${entry.key} no se desborda con texto x$scale', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(_host(entry.value(), textScale: scale));
        await tester.pump();

        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('la silueta tiene etiqueta y no revela el nombre', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        const TriviaQuestionPage(
          data: _question,
          onGuess: noop,
          onHint: noop,
          onSkip: noop,
        ),
      ),
    );

    expect(
      find.bySemanticsLabel('Silueta de un Pokémon misterioso'),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('la pregunta dice cuántas letras tiene el nombre', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        const TriviaQuestionPage(
          data: _question,
          onGuess: noop,
          onHint: noop,
          onSkip: noop,
        ),
      ),
    );

    expect(find.bySemanticsLabel('El nombre tiene 12 letras'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('el tiempo agotado se identifica sin depender del color', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const TriviaRevealPage(
          kind: TriviaRevealKind.timeUp,
          data: _reveal,
          onNext: noop,
        ),
      ),
    );

    expect(find.text('✕'), findsWidgets);
    expect(find.text('¡Tiempo agotado!'), findsOneWidget);
  });
}
