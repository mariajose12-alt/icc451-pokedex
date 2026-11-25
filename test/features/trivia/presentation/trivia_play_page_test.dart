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

  testWidgets('con la partida en curso atrás pide confirmar; seguir '
      'mantiene la pregunta', (tester) async {
    tester.view.physicalSize = const Size(900, 2400);
    addTearDown(tester.view.reset);

    final cubit = TriviaGameCubit(
      repository: FakeTriviaRepository(questions: sampleQuestions(2)),
    );
    await tester.pumpWidget(_host(cubit));
    await cubit.start();
    await tester.pump();

    // En plena partida el atrás está bloqueado (PopScope).
    final scope = find.byWidgetPredicate((w) => w is PopScope).first;
    expect(tester.widget<PopScope>(scope).canPop, isFalse);

    // Se simula el intento de salir y debe aparecer el diálogo.
    tester.widget<PopScope>(scope).onPopInvokedWithResult!(false, null);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    // Diagnóstico temporal: qué textos hay en pantalla.
    debugPrint(
      tester.allWidgets
          .whereType<Text>()
          .map((t) => t.data)
          .whereType<String>()
          .toList()
          .toString(),
    );
    debugPrint('AlertDialog: ${find.byType(AlertDialog).evaluate().length}');
    expect(find.text('¿Salir de la partida?'), findsOneWidget);

    // «Seguir jugando» cierra el diálogo y la pregunta sigue ahí.
    await tester.tap(find.text('Seguir jugando'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('¿Salir de la partida?'), findsNothing);
    expect(find.byType(TriviaQuestionPage), findsOneWidget);

    await _finish(tester, cubit);
  });

  testWidgets('sin partida en curso el atrás no se bloquea', (tester) async {
    final cubit = TriviaGameCubit(repository: FakeTriviaRepository());

    await tester.pumpWidget(_host(cubit));
    await cubit.start();
    await tester.pump();

    // Sin datos suficientes no hay partida que perder.
    final scope = find.byWidgetPredicate((w) => w is PopScope).first;
    expect(tester.widget<PopScope>(scope).canPop, isTrue);

    await _finish(tester, cubit);
  });
}
