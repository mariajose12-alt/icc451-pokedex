import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/app/app.dart';
import 'package:pokedex/core/di/service_locator.dart';
import 'package:pokedex/features/pokemon/data/fake_pokemon_repository.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:pokedex/features/settings/presentation/cubit/locale_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    preferences = await SharedPreferences.getInstance();
    getIt
      ..registerSingleton<SharedPreferences>(preferences)
      ..registerSingleton<PokemonRepository>(
        FakePokemonRepository(
          scenario: FakeScenario.empty,
          delay: Duration.zero,
        ),
      );
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('La app abre con la barra de navegación y cambia a Favoritos', (
    tester,
  ) async {
    await tester.pumpWidget(
      PokedexApp(localeCubit: LocaleCubit(preferences: preferences)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);

    // Se busca por icono para no depender del idioma del dispositivo.
    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });
}
