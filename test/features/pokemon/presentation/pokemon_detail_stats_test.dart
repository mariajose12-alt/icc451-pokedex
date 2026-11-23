import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_stat.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_stats.dart';
import 'package:pokedex/l10n/app_localizations.dart';

// Los 6 stats de Charizard.
const _charizard = <PokemonStat>[
  PokemonStat(statId: 1, baseStat: 78),
  PokemonStat(statId: 2, baseStat: 84),
  PokemonStat(statId: 3, baseStat: 78),
  PokemonStat(statId: 4, baseStat: 109),
  PokemonStat(statId: 5, baseStat: 85),
  PokemonStat(statId: 6, baseStat: 100),
];

Widget _app(Widget child, {String idioma = 'es'}) {
  return MaterialApp(
    locale: Locale(idioma),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  testWidgets('muestra los 6 nombres, valores, porcentajes y el total', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const PokemonDetailStats(stats: _charizard, total: 534)),
    );
    // Espera a que termine la animación de las barras.
    await tester.pumpAndSettle();

    for (final nombre in [
      'HP',
      'Ataque',
      'Defensa',
      'At. esp.',
      'Def. esp.',
      'Velocidad',
    ]) {
      expect(find.text(nombre), findsOneWidget);
    }

    // 78 aparece dos veces (HP y Defensa).
    expect(find.text('78'), findsNWidgets(2));
    expect(find.text('109'), findsOneWidget);
    // 109 / 255 = 43 %; 100 / 255 = 39 %.
    expect(find.text('43 %'), findsOneWidget);
    expect(find.text('39 %'), findsOneWidget);

    expect(find.text('Total'), findsOneWidget);
    expect(find.text('534'), findsOneWidget);
  });

  testWidgets('sin stats muestra el mensaje y ninguna barra', (tester) async {
    await tester.pumpWidget(
      _app(const PokemonDetailStats(stats: [], total: 0)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Estadísticas no disponibles todavía'), findsOneWidget);
    expect(find.byType(FractionallySizedBox), findsNothing);
    expect(find.text('Total'), findsNothing);
  });

  testWidgets('en inglés usa los nombres y el formato en inglés', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const PokemonDetailStats(stats: _charizard, total: 534),
        idioma: 'en',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Attack'), findsOneWidget);
    expect(find.text('Speed'), findsOneWidget);
    expect(find.text('43%'), findsOneWidget);
  });

  testWidgets('con texto al 200 % no se desborda', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: _app(const PokemonDetailStats(stats: _charizard, total: 534)),
      ),
    );
    await tester.pumpAndSettle();

    // Si algo se desbordara, Flutter lo reportaría como excepción de prueba.
    expect(tester.takeException(), isNull);
  });
}
