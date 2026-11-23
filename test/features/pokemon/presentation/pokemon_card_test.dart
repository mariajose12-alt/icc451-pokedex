import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/presentation/share/pokemon_card.dart';
import 'package:pokedex/features/pokemon/presentation/share/pokemon_card_data.dart';
import 'package:pokedex/features/pokemon/presentation/share/pokemon_card_dialog.dart';
import 'package:pokedex/l10n/app_localizations.dart';

import '../../../helpers/fake_pokemon_card_sharer.dart';

const _data = PokemonCardData(
  name: 'Bulbasaur',
  nationalDexNumber: 1,
  typeNames: ['grass', 'poison'],
  accentColor: Color(0xFF78C850),
  stats: [
    PokemonCardStat(label: 'HP', value: 45),
    PokemonCardStat(label: 'ATK', value: 49),
    PokemonCardStat(label: 'DEF', value: 49),
    PokemonCardStat(label: 'SPA', value: 65),
    PokemonCardStat(label: 'SPD', value: 65),
    PokemonCardStat(label: 'SPE', value: 45),
  ],
  total: 318,
  heightWeight: '0,7 m · 6,9 kg',
  abilities: 'Espesura · Clorofila (oculta)',
  weakTo: 'Fuego, Volador, Hielo, Psíquico',
  resists: 'Planta ×¼, Agua, Eléctrico, Lucha',
);

Widget _app(Widget child) {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('la carta muestra identidad, stats y datos', (tester) async {
    await tester.pumpWidget(_app(const PokemonCard(data: _data)));
    await tester.pumpAndSettle();

    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.text('001'), findsOneWidget);
    expect(find.text('318'), findsOneWidget);
    expect(find.text('HP'), findsOneWidget);
    expect(find.text('0,7 m · 6,9 kg'), findsOneWidget);
    expect(find.text('Espesura · Clorofila (oculta)'), findsOneWidget);
    expect(find.text('Débil contra'), findsOneWidget);
    expect(find.text('Resiste'), findsOneWidget);
    expect(find.text('POKÉDEX NACIONAL'), findsOneWidget);
  });

  testWidgets('mide siempre 378×528, aunque el texto del sistema sea grande', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: _app(const PokemonCard(data: _data)),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(PokemonCard)), const Size(378, 528));
    expect(tester.takeException(), isNull);
  });

  testWidgets('sin imagen muestra el ícono de respaldo', (tester) async {
    await tester.pumpWidget(_app(const PokemonCard(data: _data)));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.catching_pokemon), findsOneWidget);
  });

  testWidgets('Compartir llama al sharer con el nombre del archivo', (
    tester,
  ) async {
    final sharer = FakePokemonCardSharer();
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                showPokemonCardDialog(context, data: _data, sharer: sharer),
            child: const Text('abrir'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Compartir carta'));
    await tester.pumpAndSettle();

    expect(sharer.calls, 1);
    expect(sharer.lastFileName, 'pokemon-001.png');
    expect(sharer.lastText, 'Bulbasaur · N.º 001 · Pokédex');
  });

  testWidgets('si compartir falla muestra el error y deja reintentar', (
    tester,
  ) async {
    final sharer = FakePokemonCardSharer()..shouldFail = true;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                showPokemonCardDialog(context, data: _data, sharer: sharer),
            child: const Text('abrir'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Compartir carta'));
    await tester.pumpAndSettle();

    expect(
      find.text('No se pudo generar la imagen. Inténtalo de nuevo.'),
      findsOneWidget,
    );

    sharer.shouldFail = false;
    await tester.tap(find.text('Compartir carta'));
    await tester.pumpAndSettle();

    expect(sharer.calls, 2);
    expect(
      find.text('No se pudo generar la imagen. Inténtalo de nuevo.'),
      findsNothing,
    );
  });
}
