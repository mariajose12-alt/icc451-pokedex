import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_type.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_card.dart';
import 'package:pokedex/l10n/app_localizations.dart';

const Pokemon _bulbasaur = Pokemon(
  id: 1,
  name: 'bulbasaur',
  nationalDexNumber: 1,
  generationId: 1,
  height: 7,
  weight: 69,
  types: [
    PokemonType(id: 12, name: 'grass'),
    PokemonType(id: 4, name: 'poison'),
  ],
);

void main() {
  testWidgets(
    'PokemonCard muestra número, nombre y tipos, y responde al toque',
    (tester) async {
      var tocado = false;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PokemonCard(
              pokemon: _bulbasaur,
              onTap: () {
                tocado = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('#001'), findsOneWidget);
      expect(find.text('Bulbasaur'), findsOneWidget);
      expect(find.text('Grass'), findsOneWidget);
      expect(find.text('Poison'), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      expect(tocado, isTrue);
    },
  );

  testWidgets('PokemonCard no se desborda con el texto al 200% (RNF-ACC-04)', (
    tester,
  ) async {
    // Pantalla de teléfono pequeña.
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          );
        },
        home: Scaffold(
          body: PokemonCard(pokemon: _bulbasaur, onTap: () {}),
        ),
      ),
    );

    // Un desborde de pantalla se registra como excepción y haría fallar esta prueba.
    expect(tester.takeException(), isNull);
  });
}
