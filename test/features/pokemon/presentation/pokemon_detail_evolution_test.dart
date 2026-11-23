import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/domain/entities/evolution_stage.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_extras.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_extras_cubit.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_evolution.dart';
import 'package:pokedex/l10n/app_localizations.dart';

import '../../../helpers/fake_pokemon_detail_repository.dart';

EvolutionStage _stage(
  int id,
  String name, {
  int? from,
  String? trigger,
  int? level,
  int? happiness,
  String? time,
  String? item,
}) => EvolutionStage(
  speciesId: id,
  name: name,
  fromSpeciesId: from,
  trigger: trigger,
  minLevel: level,
  minHappiness: happiness,
  timeOfDay: time,
  itemName: item,
);

final PokemonExtras _eevee = PokemonExtras(
  downloaded: true,
  evolution: [
    _stage(133, 'eevee'),
    _stage(
      134,
      'vaporeon',
      from: 133,
      trigger: 'use-item',
      item: 'water-stone',
    ),
    _stage(
      196,
      'espeon',
      from: 133,
      trigger: 'level-up',
      happiness: 160,
      time: 'day',
    ),
    _stage(
      197,
      'umbreon',
      from: 133,
      trigger: 'level-up',
      happiness: 160,
      time: 'night',
    ),
    _stage(471, 'glaceon', from: 133, trigger: 'level-up', level: 20),
    _stage(700, 'sylveon', from: 133, trigger: 'trade'),
  ],
);

void main() {
  late FakePokemonDetailRepository repository;
  late List<int> opened;

  setUp(() {
    repository = FakePokemonDetailRepository();
    opened = [];
  });

  tearDown(() async {
    await repository.extrasController.close();
  });

  Future<void> pumpEvolution(
    WidgetTester tester, {
    double textScale = 1,
  }) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: BlocProvider(
              create: (_) =>
                  PokemonExtrasCubit(repository: repository, pokemonId: 133),
              child: SingleChildScrollView(
                child: PokemonDetailEvolution(
                  currentSpeciesId: 133,
                  onOpenPokemon: opened.add,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('sin descargar muestra el aviso', (tester) async {
    await pumpEvolution(tester);

    expect(
      find.text('Estos datos se descargan al abrir el Pokémon con conexión'),
      findsOneWidget,
    );
  });

  testWidgets('descargado sin evoluciones dice que no evoluciona', (
    tester,
  ) async {
    await pumpEvolution(tester);

    repository.extrasController.add(
      PokemonExtras(downloaded: true, evolution: [_stage(132, 'ditto')]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Este Pokémon no evoluciona'), findsOneWidget);
  });

  testWidgets('muestra las ramas y la condición de cada una', (tester) async {
    await pumpEvolution(tester);

    repository.extrasController.add(_eevee);
    await tester.pumpAndSettle();

    expect(find.text('Eevee'), findsOneWidget);
    expect(find.text('Vaporeon'), findsOneWidget);
    expect(find.text('Usar Water Stone'), findsOneWidget);
    expect(find.text('Amistad alta · de día'), findsOneWidget);
    expect(find.text('Amistad alta · de noche'), findsOneWidget);
    expect(find.text('Nivel 20'), findsOneWidget);
    expect(find.text('Intercambio'), findsOneWidget);
    expect(find.text('Línea evolutiva'), findsOneWidget);
    // La etapa actual se marca con texto, no solo con color.
    expect(find.text('Actual'), findsOneWidget);
  });

  testWidgets('tocar una etapa avisa con su id; la actual no', (tester) async {
    await pumpEvolution(tester);

    repository.extrasController.add(_eevee);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Vaporeon'));
    await tester.pump();
    expect(opened, [134]);

    await tester.tap(find.text('Eevee'));
    await tester.pump();
    expect(opened, [134]);
  });

  testWidgets('con texto al 200 % no se desborda', (tester) async {
    await pumpEvolution(tester, textScale: 2);

    repository.extrasController.add(_eevee);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
