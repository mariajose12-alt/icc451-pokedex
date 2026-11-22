import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/trivia/presentation/cubit/trivia_game_cubit.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_no_data_page.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_play_page.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_question_page.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_result_page.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_reveal_page.dart';
import 'package:pokedex/l10n/app_localizations.dart';

import '../../../helpers/fake_trivia_repository.dart';

Widget _host(TriviaGameCubit cubit) {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<TriviaGameCubit>.value(
      value: cubit,
      child: const TriviaPlayPage(),
    ),
  );
}

// Se cierra el cubit dentro del test para que no quede el reloj activo.
Future<void> _finish(WidgetTester tester, TriviaGameCubit cubit) async {
  await tester.pumpWidget(const SizedBox());
  await cubit.close();
}

void main() {
  testWidgets('sin Pokémon suficientes se ve la pantalla de datos (PA-11)', (
    tester,
  ) async {
    final cubit = TriviaGameCubit(repository: FakeTriviaRepository());

    await tester.pumpWidget(_host(cubit));
    await cubit.start();
    await tester.pump();

    expect(find.byType(TriviaNoDataPage), findsOneWidget);
    expect(find.byType(TriviaQuestionPage), findsNothing);
    await _finish(tester, cubit);
  });

  testWidgets(
    'una partida completa pasa por pregunta, revelación y resultado',
    (tester) async {
      tester.view.physicalSize = const Size(900, 2400);
      addTearDown(tester.view.reset);

      final cubit = TriviaGameCubit(
        repository: FakeTriviaRepository(questions: sampleQuestions(2)),
      );
      await tester.pumpWidget(_host(cubit));
      await cubit.start();
      await tester.pump();
      expect(find.byType(TriviaQuestionPage), findsOneWidget);

      // Se escribe en el campo y se envía con la tecla "listo".
      await tester.enterText(find.byType(TextField), 'Pikachu');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.byType(TriviaRevealPage), findsOneWidget);

      await cubit.next();
      await tester.pump();
      // El campo empieza vacío en la pregunta siguiente.
      expect(find.byType(TriviaQuestionPage), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );

      cubit.skip();
      await tester.pump();
      await cubit.next();
      await tester.pump();
      expect(find.byType(TriviaResultPage), findsOneWidget);
      await _finish(tester, cubit);
    },
  );
}
