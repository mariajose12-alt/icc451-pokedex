import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/onboarding/presentation/onboarding_page.dart';
import 'package:pokedex/l10n/app_localizations.dart';

Future<void> _pump(
  WidgetTester tester, {
  required Future<void> Function() onFinished,
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: true,
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
      home: OnboardingPage(onFinished: onFinished),
    ),
  );
  await tester.pump();
}

Future<void> _next(WidgetTester tester) async {
  await tester.tap(find.text('Siguiente'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('muestra el primer paso con Saltar, Siguiente y la pista', (
    tester,
  ) async {
    await _pump(tester, onFinished: () async {});

    expect(find.text('Explora cada Pokémon'), findsOneWidget);
    expect(find.text('Paso 1 de 4'), findsOneWidget);
    expect(find.text('Saltar'), findsOneWidget);
    expect(find.text('Siguiente'), findsOneWidget);
    expect(find.text('Empezar'), findsNothing);
    expect(find.text('Pruébalo: toca la tarjeta'), findsOneWidget);
    expect(find.text('Dónde: pestaña «Pokédex»'), findsOneWidget);
  });

  testWidgets('Saltar termina la introducción', (tester) async {
    var finished = 0;
    await _pump(tester, onFinished: () async => finished++);

    await tester.tap(find.text('Saltar'));
    await tester.pump();

    expect(finished, 1);
  });

  testWidgets('tocar la tarjeta de práctica muestra tipo y estadística', (
    tester,
  ) async {
    await _pump(tester, onFinished: () async {});
    expect(find.text('Eléctrico'), findsNothing);

    await tester.tap(find.text('#025  Pikachu'));
    await tester.pumpAndSettle();

    expect(find.text('Eléctrico'), findsOneWidget);
    expect(find.text('Velocidad  90'), findsOneWidget);
    expect(
      find.text('¡Así de fácil! Cada Pokémon de la Pokédex se abre igual.'),
      findsOneWidget,
    );
  });

  testWidgets('tocar el corazón de práctica confirma el guardado', (
    tester,
  ) async {
    await _pump(tester, onFinished: () async {});
    await _next(tester);

    expect(find.text('Guarda tus favoritos'), findsOneWidget);
    expect(find.text('Dónde: pestaña «Favoritos»'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(
      find.text('¡Guardado! Tus favoritos se ven aunque no tengas conexión.'),
      findsOneWidget,
    );
  });

  testWidgets('tocar el lente de práctica cambia de estado', (tester) async {
    await _pump(tester, onFinished: () async {});
    await _next(tester);
    await _next(tester);

    expect(find.text('Mira si estás en línea'), findsOneWidget);
    expect(find.text('Dónde: arriba, en la barra de estado'), findsOneWidget);
    expect(find.text('En línea'), findsOneWidget);

    await tester.tap(find.text('En línea'));
    await tester.pumpAndSettle();
    expect(find.text('Sincronizando…'), findsOneWidget);

    await tester.tap(find.text('Sincronizando…'));
    await tester.pumpAndSettle();
    expect(find.text('Sin conexión'), findsOneWidget);
  });

  testWidgets('cuatro pasos: Empezar termina una sola vez y sin Saltar', (
    tester,
  ) async {
    var finished = 0;
    await _pump(tester, onFinished: () async => finished++);

    await _next(tester);
    await _next(tester);
    await _next(tester);

    expect(find.text('Juega a la trivia'), findsOneWidget);
    expect(find.text('Paso 4 de 4'), findsOneWidget);
    // Saltar guarda su espacio, pero no se ve ni se puede tocar.
    expect(find.text('Saltar').hitTestable(), findsNothing);
    expect(finished, 0);

    // El «?» se revela al tocarlo.
    await tester.tap(find.text('?'));
    await tester.pumpAndSettle();
    expect(find.text('Pikachu'), findsOneWidget);

    await tester.tap(find.text('Empezar'));
    await tester.pump();
    expect(finished, 1);
  });

  testWidgets('con texto al 200 % no se desborda en ningún paso', (
    tester,
  ) async {
    await _pump(tester, onFinished: () async {}, textScale: 2);
    expect(tester.takeException(), isNull);

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
