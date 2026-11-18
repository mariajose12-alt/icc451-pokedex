import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/domain/entities/type_chart.dart';
import 'package:pokedex/features/pokemon/domain/entities/type_efficacy.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_matchups.dart';
import 'package:pokedex/l10n/app_localizations.dart';

import '../../../helpers/fake_type_chart_repository.dart';

TypeEfficacy _e(int attacker, int defender, int factor) => TypeEfficacy(
  damageTypeId: attacker,
  targetTypeId: defender,
  damageFactor: factor,
);

Widget _app(FakeTypeChartRepository repository) {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SingleChildScrollView(
        // Defensor: Fuego (id 10).
        child: PokemonDetailMatchups(
          repository: repository,
          defenderTypeIds: const [10],
        ),
      ),
    ),
  );
}

void main() {
  late FakeTypeChartRepository repository;

  setUp(() {
    repository = FakeTypeChartRepository();
  });

  tearDown(() async {
    await repository.dispose();
  });

  testWidgets('sin tabla muestra el mensaje de no disponibles', (tester) async {
    await tester.pumpWidget(_app(repository));

    expect(find.text('Matchups no disponibles todavía'), findsOneWidget);
    expect(find.text('Débil contra'), findsNothing);
  });

  testWidgets('al llegar la tabla muestra los grupos con su multiplicador', (
    tester,
  ) async {
    await tester.pumpWidget(_app(repository));

    // Agua ×2, Planta ×0.5 y Tierra ×0 contra Fuego (valores de prueba).
    repository.chartController.add(
      TypeChart([_e(11, 10, 200), _e(12, 10, 50), _e(5, 10, 0)]),
    );
    repository.namesController.add(const {
      5: 'ground',
      10: 'fire',
      11: 'water',
      12: 'grass',
    });
    await tester.pumpAndSettle();

    expect(find.text('Matchups no disponibles todavía'), findsNothing);
    expect(find.text('Débil contra'), findsOneWidget);
    expect(find.text('Resiste'), findsOneWidget);
    expect(find.text('Inmune a'), findsOneWidget);

    expect(find.text('Water'), findsOneWidget);
    expect(find.text('×2'), findsOneWidget);
    expect(find.text('Grass'), findsOneWidget);
    expect(find.text('×½'), findsOneWidget);
    expect(find.text('Ground'), findsOneWidget);
    expect(find.text('×0'), findsOneWidget);
  });

  testWidgets('un grupo sin elementos no se dibuja', (tester) async {
    await tester.pumpWidget(_app(repository));

    // Solo una debilidad: no debe aparecer "Resiste" ni "Inmune a".
    repository.chartController.add(TypeChart([_e(11, 10, 200)]));
    repository.namesController.add(const {10: 'fire', 11: 'water'});
    await tester.pumpAndSettle();

    expect(find.text('Débil contra'), findsOneWidget);
    expect(find.text('Resiste'), findsNothing);
    expect(find.text('Inmune a'), findsNothing);
  });

  test('las etiquetas de multiplicador cubren todos los valores', () {
    expect(matchupMultiplierLabel(400), '×4');
    expect(matchupMultiplierLabel(200), '×2');
    expect(matchupMultiplierLabel(50), '×½');
    expect(matchupMultiplierLabel(25), '×¼');
    expect(matchupMultiplierLabel(0), '×0');
  });
}
