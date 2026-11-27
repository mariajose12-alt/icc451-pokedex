import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/domain/entities/move_version_group.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_moves_cubit.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_regions.dart';
import 'package:pokedex/l10n/app_localizations.dart';

import '../../../helpers/fake_pokemon_moves_repository.dart';

const _groups = [
  MoveVersionGroup(id: 25, name: 'scarlet-violet'),
  MoveVersionGroup(id: 3, name: 'gold-silver'),
  MoveVersionGroup(id: 2, name: 'yellow'),
  MoveVersionGroup(id: 1, name: 'red-blue'),
];

void main() {
  late FakePokemonMovesRepository repository;

  setUp(() {
    repository = FakePokemonMovesRepository();
  });

  tearDown(() async {
    await repository.dispose();
  });

  // Pantalla de teléfono: el mapa mide el ancho disponible y así cabe entero.
  Future<void> pumpRegions(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          // El Cubit se crea dentro del test (no en setUp) para que sus
          // suscripciones usen el reloj falso y tester.pump() las entregue.
          body: BlocProvider<PokemonMovesCubit>(
            create: (_) =>
                PokemonMovesCubit(repository: repository, pokemonId: 25),
            child: const SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: PokemonDetailRegions(),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> loadGroups(WidgetTester tester) async {
    repository.groupsController.add(_groups);
    await tester.pump();
    await tester.pump();
  }

  testWidgets('sin versiones guardadas no hay mapa', (tester) async {
    await pumpRegions(tester);
    repository.groupsController.add(const []);
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const ValueKey('region-kanto')), findsNothing);
  });

  testWidgets('muestra la primera región con datos y sus entregas', (
    tester,
  ) async {
    await pumpRegions(tester);
    await loadGroups(tester);

    expect(find.text('KANTO · GENERACIÓN I'), findsOneWidget);
    expect(find.text('Aparece en 2 entregas'), findsOneWidget);
    expect(find.text('Rojo · Azul'), findsOneWidget);
    expect(find.text('Amarillo'), findsOneWidget);
    expect(
      find.text('Iniciales de la región: Bulbasaur · Charmander · Squirtle'),
      findsOneWidget,
    );
  });

  testWidgets('tocar otra isla cambia el panel', (tester) async {
    await pumpRegions(tester);
    await loadGroups(tester);

    await tester.tap(find.byKey(const ValueKey('region-paldea')));
    await tester.pump();

    expect(find.text('PALDEA · GENERACIÓN IX'), findsOneWidget);
    expect(find.text('Aparece en 1 entrega'), findsOneWidget);
    expect(find.text('Escarlata · Púrpura'), findsOneWidget);
    expect(find.text('Rojo · Azul'), findsNothing);
  });

  testWidgets('una región sin datos lo dice con un texto', (tester) async {
    await pumpRegions(tester);
    await loadGroups(tester);

    await tester.tap(find.byKey(const ValueKey('region-unova')));
    await tester.pump();

    expect(
      find.text('No hay datos de este Pokémon en juegos de Teselia.'),
      findsOneWidget,
    );
  });
}
