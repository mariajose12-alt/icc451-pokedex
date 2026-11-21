import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/domain/entities/move_learn_method.dart';
import 'package:pokedex/features/pokemon/domain/entities/move_version_group.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_move.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_moves_cubit.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_moves.dart';
import 'package:pokedex/l10n/app_localizations.dart';

import '../../../helpers/fake_pokemon_moves_repository.dart';

const _newest = MoveVersionGroup(id: 25, name: 'scarlet-violet');
const _oldest = MoveVersionGroup(id: 1, name: 'red-blue');

void main() {
  late FakePokemonMovesRepository repository;

  setUp(() {
    repository = FakePokemonMovesRepository();
  });

  tearDown(() async {
    await repository.dispose();
  });

  Future<void> pumpMoves(WidgetTester tester, {double textScale = 1}) async {
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
                  PokemonMovesCubit(repository: repository, pokemonId: 1),
              child: const CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.all(16),
                    sliver: PokemonDetailMoves(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> loadData(WidgetTester tester, List<PokemonMove> moves) async {
    repository.groupsController.add(const [_newest, _oldest]);
    await tester.pump();
    repository.movesController.add(moves);
    await tester.pumpAndSettle();
  }

  testWidgets('sin versiones muestra el aviso de descarga', (tester) async {
    await pumpMoves(tester);

    expect(
      find.text('Estos datos se descargan al abrir el Pokémon con conexión'),
      findsOneWidget,
    );
  });

  testWidgets('con datos muestra la versión, los métodos y las filas', (
    tester,
  ) async {
    await pumpMoves(tester);

    await loadData(tester, const [
      PokemonMove(moveId: 1, name: 'tackle', level: 1),
      PokemonMove(moveId: 2, name: 'vine-whip', level: 7),
    ]);

    expect(find.text('Scarlet Violet'), findsOneWidget);
    expect(find.text('MT'), findsOneWidget);
    expect(find.text('Tutor'), findsOneWidget);
    expect(find.text('Huevo'), findsOneWidget);
    expect(find.text('Tackle'), findsOneWidget);
    expect(find.text('Nv.1'), findsOneWidget);
    expect(find.text('Vine Whip'), findsOneWidget);
    expect(find.text('Nv.7'), findsOneWidget);
  });

  testWidgets('tocar MT consulta ese método', (tester) async {
    await pumpMoves(tester);
    await loadData(tester, const []);

    await tester.tap(find.text('MT'));
    await tester.pumpAndSettle();

    expect(repository.requests.last, (25, MoveLearnMethod.machine));
  });

  testWidgets('con MT el orden por nivel desaparece', (tester) async {
    await pumpMoves(tester);
    await loadData(tester, const []);
    expect(find.text('Ordenar por'), findsOneWidget);

    await tester.tap(find.text('MT'));
    await tester.pumpAndSettle();

    expect(find.text('Ordenar por'), findsNothing);
  });

  testWidgets('la hoja de versiones cambia la versión elegida', (tester) async {
    await pumpMoves(tester);
    await loadData(tester, const []);

    await tester.tap(find.text('Scarlet Violet'));
    await tester.pumpAndSettle();

    expect(find.text('Versión del juego'), findsOneWidget);
    await tester.tap(find.text('Red Blue'));
    await tester.pumpAndSettle();

    expect(repository.requests.last, (1, MoveLearnMethod.levelUp));
    expect(find.text('Versión del juego'), findsNothing);
  });

  testWidgets('sin movimientos por el método muestra el estado vacío', (
    tester,
  ) async {
    await pumpMoves(tester);

    await loadData(tester, const []);

    expect(find.text('Sin movimientos por este método'), findsOneWidget);
  });

  testWidgets('la lista es virtualizada: no construye las 500 filas', (
    tester,
  ) async {
    await pumpMoves(tester);

    await loadData(tester, [
      for (var i = 0; i < 500; i++)
        PokemonMove(moveId: i, name: 'move-$i', level: i + 1),
    ]);

    // Se ve el principio y no el final.
    expect(find.text('Move 0'), findsOneWidget);
    expect(find.text('Move 499'), findsNothing);

    // Al bajar, el final aparece.
    await tester.scrollUntilVisible(
      find.text('Move 499'),
      2000,
      maxScrolls: 200,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Move 499'), findsOneWidget);
  });

  testWidgets('con texto al 200 % no se desborda', (tester) async {
    await pumpMoves(tester, textScale: 2);

    await loadData(tester, const [
      PokemonMove(moveId: 1, name: 'tackle', level: 1),
    ]);

    expect(tester.takeException(), isNull);
  });
}
