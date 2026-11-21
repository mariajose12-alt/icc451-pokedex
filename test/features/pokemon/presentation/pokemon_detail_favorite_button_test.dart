import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/favorites/presentation/cubit/favorite_cubit.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_favorite_button.dart';
import 'package:pokedex/l10n/app_localizations.dart';

import '../../../helpers/fake_favorites_repository.dart';

void main() {
  late FakeFavoritesRepository repository;

  setUp(() {
    repository = FakeFavoritesRepository();
  });

  tearDown(() async {
    await repository.dispose();
  });

  Future<void> pumpButton(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: BlocProvider(
              create: (_) =>
                  FavoriteCubit(repository: repository, pokemonId: 1),
              child: const PokemonDetailFavoriteButton(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empieza como «Agregar a favoritos»', (tester) async {
    await pumpButton(tester);

    expect(find.byTooltip('Agregar a favoritos'), findsOneWidget);
    expect(find.byTooltip('Quitar de favoritos'), findsNothing);
  });

  testWidgets('tocar lo vuelve favorito y vuelve a quitarlo', (tester) async {
    await pumpButton(tester);

    await tester.tap(find.byTooltip('Agregar a favoritos'));
    await tester.pumpAndSettle();

    expect(repository.toggleCalls, 1);
    expect(find.byTooltip('Quitar de favoritos'), findsOneWidget);

    await tester.tap(find.byTooltip('Quitar de favoritos'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Agregar a favoritos'), findsOneWidget);
  });

  testWidgets('mide al menos 48 px de toque', (tester) async {
    await pumpButton(tester);

    final size = tester.getSize(find.byTooltip('Agregar a favoritos'));

    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets('el lector de pantalla anuncia la acción según el estado', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpButton(tester);

    // Estado inicial: no es favorito, la acción es agregar.
    expect(find.bySemanticsLabel('Agregar a favoritos'), findsOneWidget);
    expect(find.bySemanticsLabel('Quitar de favoritos'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Agregar a favoritos'));
    await tester.pumpAndSettle();

    // Ya es favorito: ahora el botón anuncia la acción contraria.
    expect(find.bySemanticsLabel('Quitar de favoritos'), findsOneWidget);
    expect(find.bySemanticsLabel('Agregar a favoritos'), findsNothing);

    handle.dispose();
  });
}
