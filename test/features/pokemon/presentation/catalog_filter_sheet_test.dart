import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/data/preferences/catalog_query_store.dart';
import 'package:pokedex/features/pokemon/domain/entities/catalogo_query.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/repositories/type_chart_repository.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_bloc.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_event.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_state.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/catalog_view_mode_cubit.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/catalog_filter_sheet.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/catalog_toolbar.dart';
import 'package:pokedex/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/controllable_pokemon_repository.dart';
import '../../../helpers/fake_type_chart_repository.dart';

/// Bloc que solo anota los eventos que recibe: así se comprueba qué manda la
/// hoja sin depender de la base ni del debounce.
class _RecordingCatalogBloc extends CatalogBloc {
  _RecordingCatalogBloc({required super.repository, required super.queryStore});

  final List<CatalogEvent> events = [];

  @override
  void add(CatalogEvent event) => events.add(event);

  /// Fija el estado que ve la pantalla.
  void show(CatalogState state) => emit(state);
}

List<Pokemon> _pokemon(int n) => [
  for (var i = 1; i <= n; i++)
    Pokemon(
      id: i,
      name: 'p$i',
      nationalDexNumber: i,
      generationId: 1,
      height: 1,
      weight: 1,
      types: const [],
    ),
];

void main() {
  late _RecordingCatalogBloc bloc;
  late CatalogViewModeCubit viewModeCubit;
  late FakeTypeChartRepository typeRepository;
  late List<CatalogViewMode> changedModes;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    bloc = _RecordingCatalogBloc(
      repository: ControllablePokemonRepository(),
      queryStore: CatalogQueryStore(preferences: preferences),
    );
    viewModeCubit = CatalogViewModeCubit(preferences: preferences);
    typeRepository = FakeTypeChartRepository();
    changedModes = [];
  });

  tearDown(() async {
    await bloc.close();
    await viewModeCubit.close();
    await typeRepository.dispose();
  });

  // Pantalla de teléfono, en español.
  Future<void> pumpPhone(WidgetTester tester, Widget body) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: body),
      ),
    );
  }

  // Abre la hoja desde un botón de prueba y le llegan los nombres de tipo.
  Future<void> openSheet(
    WidgetTester tester, {
    CatalogoQuery initial = const CatalogoQuery(),
  }) async {
    await pumpPhone(
      tester,
      Builder(
        builder: (context) => Center(
          child: TextButton(
            onPressed: () {
              unawaited(
                showCatalogFilterSheet(
                  context,
                  bloc: bloc,
                  viewModeCubit: viewModeCubit,
                  typeNames: typeRepository.watchTypeNames(),
                  initial: initial,
                  onViewModeChanged: changedModes.add,
                ),
              );
            },
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    typeRepository.namesController.add({
      10: 'fire',
      11: 'water',
      18: 'unknown',
    });
    // Dos pump: el primero entrega el evento del stream y el segundo
    // reconstruye el StreamBuilder con los tipos.
    await tester.pump();
    await tester.pump();
  }

  CatalogFilterChanged lastFilter() =>
      bloc.events.whereType<CatalogFilterChanged>().last;

  group('Hoja de filtros', () {
    testWidgets('muestra Vista, Orden, Tipo y Generación', (tester) async {
      await openSheet(tester);

      expect(find.text('Filtros y vista'), findsOneWidget);
      for (final seccion in ['Vista', 'Orden', 'Tipo', 'Generación']) {
        expect(find.text(seccion), findsOneWidget);
      }
      expect(find.text('Cuadrícula'), findsOneWidget);
      expect(find.text('Lista'), findsOneWidget);
      expect(find.text('1 · Kanto'), findsOneWidget);
      expect(find.text('9 · Paldea'), findsOneWidget);
    });

    testWidgets('ofrece los tipos normales y oculta los especiales', (
      tester,
    ) async {
      await openSheet(tester);

      expect(find.text('Fire'), findsOneWidget);
      expect(find.text('Water'), findsOneWidget);
      expect(find.text('Unknown'), findsNothing);
    });

    testWidgets('tocar Lista avisa el cambio de vista', (tester) async {
      await openSheet(tester);

      await tester.tap(find.text('Lista'));
      await tester.pump();

      expect(changedModes, [CatalogViewMode.list]);
    });

    testWidgets('tipo, generación y orden mandan el criterio completo', (
      tester,
    ) async {
      await openSheet(tester);

      await tester.tap(find.text('Fire'));
      await tester.pump();
      await tester.tap(find.text('1 · Kanto'));
      await tester.pump();
      await tester.tap(find.text('Nombre'));
      await tester.pump();

      expect(bloc.events.whereType<CatalogFilterChanged>(), hasLength(3));
      final ultimo = lastFilter();
      expect(ultimo.tipoIds, {10});
      expect(ultimo.generacionIds, {1});
      expect(ultimo.orden, CatalogoOrden.nombre);
    });

    testWidgets('tocar un tipo ya elegido lo quita', (tester) async {
      await openSheet(tester, initial: const CatalogoQuery(tipoIds: {10}));

      await tester.tap(find.text('Fire'));
      await tester.pump();

      expect(lastFilter().tipoIds, isEmpty);
    });

    testWidgets('Limpiar vuelve al criterio por defecto', (tester) async {
      await openSheet(
        tester,
        initial: const CatalogoQuery(
          tipoIds: {10},
          generacionIds: {1},
          orden: CatalogoOrden.nombre,
        ),
      );

      await tester.tap(find.text('Limpiar'));
      await tester.pump();

      final ultimo = lastFilter();
      expect(ultimo.tipoIds, isEmpty);
      expect(ultimo.generacionIds, isEmpty);
      expect(ultimo.orden, CatalogoOrden.numero);
    });

    testWidgets('Limpiar no hace nada si no hay filtros', (tester) async {
      await openSheet(tester);

      await tester.tap(find.text('Limpiar'));
      await tester.pump();

      expect(bloc.events, isEmpty);
    });

    testWidgets('el botón principal dice cuántos resultados hay y cierra', (
      tester,
    ) async {
      bloc.show(CatalogSuccess(pokemon: _pokemon(12)));
      await openSheet(tester);

      expect(find.text('Ver 12 resultados'), findsOneWidget);

      await tester.tap(find.text('Ver 12 resultados'));
      await tester.pumpAndSettle();

      expect(find.text('Filtros y vista'), findsNothing);
    });
  });

  group('Barra del catálogo', () {
    Future<void> pumpToolbar(WidgetTester tester) {
      return pumpPhone(
        tester,
        RepositoryProvider<TypeChartRepository>.value(
          value: typeRepository,
          child: MultiBlocProvider(
            providers: [
              BlocProvider<CatalogBloc>.value(value: bloc),
              BlocProvider<CatalogViewModeCubit>.value(value: viewModeCubit),
            ],
            child: CatalogToolbar(
              initialText: '',
              onViewModeChanged: changedModes.add,
            ),
          ),
        ),
      );
    }

    testWidgets('solo tiene búsqueda y botón Filtros, sin selector de vista', (
      tester,
    ) async {
      await pumpToolbar(tester);

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.filter_alt), findsOneWidget);
      expect(find.byType(SegmentedButton<CatalogViewMode>), findsNothing);
      expect(find.byIcon(Icons.grid_view), findsNothing);
      expect(find.byIcon(Icons.view_list), findsNothing);
    });

    testWidgets('el botón cuenta los criterios activos', (tester) async {
      await pumpToolbar(tester);
      expect(find.text('2'), findsNothing);

      bloc.show(
        CatalogSuccess(
          pokemon: const [],
          query: const CatalogoQuery(tipoIds: {10}, generacionIds: {1}),
        ),
      );
      await tester.pump();

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('tocar Filtros abre la hoja', (tester) async {
      await pumpToolbar(tester);

      await tester.tap(find.byIcon(Icons.filter_alt));
      await tester.pumpAndSettle();

      expect(find.text('Filtros y vista'), findsOneWidget);
    });
  });
}
