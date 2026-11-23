import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_stat.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_type.dart';
import 'package:pokedex/features/pokemon/domain/entities/type_chart.dart';
import 'package:pokedex/features/pokemon/domain/entities/type_efficacy.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_stats_radar.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_content.dart';
import 'package:pokedex/l10n/app_localizations.dart';

import '../../../helpers/fake_type_chart_repository.dart';

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
  stats: [
    PokemonStat(statId: 1, baseStat: 45),
    PokemonStat(statId: 2, baseStat: 49),
    PokemonStat(statId: 3, baseStat: 49),
    PokemonStat(statId: 4, baseStat: 65),
    PokemonStat(statId: 5, baseStat: 65),
    PokemonStat(statId: 6, baseStat: 45),
  ],
);

Widget _app(Widget child) {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('el header muestra número, nombre y los dos tipos', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const PokemonDetailContent(pokemon: _bulbasaur)),
    );
    await tester.pumpAndSettle();

    expect(find.text('#001'), findsOneWidget);
    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.text('Grass'), findsOneWidget);
    expect(find.text('Poison'), findsOneWidget);
  });

  testWidgets('abre en Resumen con los stats, el total y las medidas', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const PokemonDetailContent(pokemon: _bulbasaur)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Estadísticas base'), findsOneWidget);
    // 45 + 49 + 49 + 65 + 65 + 45 = 318.
    expect(find.text('318'), findsOneWidget);
    expect(find.text('Datos'), findsOneWidget);
    expect(find.text('Altura'), findsOneWidget);
    expect(find.text('Peso'), findsOneWidget);
  });

  testWidgets('Evolución y Movs. muestran el aviso de sección pendiente', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const PokemonDetailContent(pokemon: _bulbasaur)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Evolución'));
    await tester.pumpAndSettle();
    expect(find.text('Esta sección estará disponible pronto'), findsOneWidget);
    expect(find.text('Estadísticas base'), findsNothing);

    await tester.tap(find.text('Movs.'));
    await tester.pumpAndSettle();
    expect(find.text('Esta sección estará disponible pronto'), findsOneWidget);
  });

  testWidgets('Combate muestra los matchups y Resumen los oculta', (
    tester,
  ) async {
    final repository = FakeTypeChartRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      _app(
        PokemonDetailContent(
          pokemon: _bulbasaur,
          typeChartRepository: repository,
        ),
      ),
    );

    // Primero se abre Combate: así el cubit ya está escuchando los streams.
    await tester.tap(find.text('Combate'));
    await tester.pump();

    // Fuego (id 10) pega ×2 a Planta (id 12).
    repository.chartController.add(
      TypeChart(const [
        TypeEfficacy(damageTypeId: 10, targetTypeId: 12, damageFactor: 200),
      ]),
    );
    repository.namesController.add(const {10: 'fire', 12: 'grass'});
    await tester.pumpAndSettle();

    expect(find.text('Débil contra'), findsOneWidget);
    expect(find.text('×2'), findsOneWidget);

    await tester.tap(find.text('Resumen'));
    await tester.pumpAndSettle();

    expect(find.text('Débil contra'), findsNothing);
    expect(find.text('Estadísticas base'), findsOneWidget);
  });

  testWidgets('Combate sin repositorio queda vacío y no falla', (tester) async {
    await tester.pumpWidget(
      _app(const PokemonDetailContent(pokemon: _bulbasaur)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Combate'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Débil contra'), findsNothing);
  });

  testWidgets('con texto al 200 % no se desborda', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: _app(const PokemonDetailContent(pokemon: _bulbasaur)),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('muestra los tres botones de acción rápida', (tester) async {
    await tester.pumpWidget(
      _app(const PokemonDetailContent(pokemon: _bulbasaur)),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Ver versión shiny'), findsOneWidget);
    expect(find.byTooltip('Cambiar de forma'), findsOneWidget);
    expect(find.byTooltip('Compartir'), findsOneWidget);
  });

  testWidgets('los botones de acción miden al menos 48 px de toque', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const PokemonDetailContent(pokemon: _bulbasaur)),
    );
    await tester.pumpAndSettle();

    final size = tester.getSize(find.byTooltip('Compartir'));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets('Resumen muestra el radar de stats', (tester) async {
    await tester.pumpWidget(
      _app(const PokemonDetailContent(pokemon: _bulbasaur)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PokemonDetailStatsRadar), findsOneWidget);
    // Las barras y el total siguen ahí: el radar no reemplaza los números.
    expect(find.text('318'), findsOneWidget);
  });

  testWidgets('el radar no se dibuja con menos de 3 stats', (tester) async {
    await tester.pumpWidget(
      _app(
        const PokemonDetailStatsRadar(
          stats: [
            PokemonStat(statId: 1, baseStat: 45),
            PokemonStat(statId: 2, baseStat: 49),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Con menos de 3 stats el radar devuelve un SizedBox vacío: no tiene
    // ningún CustomPaint dentro.
    expect(
      find.descendant(
        of: find.byType(PokemonDetailStatsRadar),
        matching: find.byType(CustomPaint),
      ),
      findsNothing,
    );
  });
}
