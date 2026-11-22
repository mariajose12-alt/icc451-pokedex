import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/trivia/presentation/cubit/trivia_ranking_cubit.dart';
import 'package:pokedex/features/trivia/presentation/models/trivia_view_data.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_achievements_page.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_ranking_page.dart';
import 'package:pokedex/l10n/app_localizations.dart';

import '../../../helpers/fake_trivia_repository.dart';

Widget _host(Widget child) {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

void main() {
  testWidgets('el ranking sin partidas muestra el estado vacío', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(TriviaRankingPage(entries: const [], onBack: () {})),
    );
    await tester.pump();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(TriviaRankingPage)),
    )!;
    expect(find.text(l10n.triviaRankingEmptyTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('los logros sin partidas se dibujan bloqueados', (tester) async {
    await tester.pumpWidget(
      _host(
        TriviaAchievementsPage(
          achievements: [
            for (var i = 0; i < 8; i++)
              TriviaAchievementData(
                name: 'Logro $i',
                description: 'Descripción',
                unlocked: false,
                progress: 0,
                target: 10,
              ),
          ],
          onBack: () {},
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(TriviaAchievementsPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('el cubit del ranking arranca vacío y se actualiza', () async {
    final cubit = TriviaRankingCubit(repository: FakeTriviaRepository());

    expect(cubit.state, isEmpty);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state, isEmpty);

    await cubit.close();
  });
}
