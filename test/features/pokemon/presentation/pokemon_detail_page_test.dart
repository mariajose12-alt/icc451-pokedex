import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_type.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_detail_cubit.dart';
import 'package:pokedex/features/pokemon/presentation/pages/pokemon_detail_page.dart';
import 'package:pokedex/l10n/app_localizations.dart';

import '../../../helpers/controllable_pokemon_repository.dart';

const Pokemon _bulbasaur = Pokemon(
  id: 1,
  name: 'bulbasaur',
  nationalDexNumber: 1,
  generationId: 1,
  height: 7, // 0,7 m
  weight: 69, // 6,9 kg
  types: [
    PokemonType(id: 12, name: 'grass'),
    PokemonType(id: 4, name: 'poison'),
  ],
);

void main() {
  late ControllablePokemonRepository repository;

  setUp(() {
    repository = ControllablePokemonRepository();
  });

  tearDown(() async {
    await repository.pokemonController.close();
  });

  // Monta la pantalla con su Cubit y los textos en español.
  Future<void> pumpPage(WidgetTester tester) async {
    final cubit = PokemonDetailCubit(repository: repository, pokemonId: 1);
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<PokemonDetailCubit>.value(
          value: cubit,
          child: const PokemonDetailPage(),
        ),
      ),
    );
  }

  testWidgets('mientras la base no responde, muestra el indicador de carga', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('con un Pokémon guardado muestra identidad y medidas', (
    tester,
  ) async {
    await pumpPage(tester);

    repository.pokemonController.add(_bulbasaur);
    await tester.pump();

    expect(find.text('#001'), findsOneWidget);
    expect(find.text('Bulbasaur'), findsOneWidget);
    // Dos tipos: se muestran los dos (RF-DET-01).
    expect(find.text('Grass'), findsOneWidget);
    expect(find.text('Poison'), findsOneWidget);
    // Medidas convertidas de decímetros/hectogramos, con coma en español.
    expect(find.text('0,7 m'), findsOneWidget);
    expect(find.text('6,9 kg'), findsOneWidget);
    // Sin URLs de imagen, aparece la pokébola de respaldo.
    expect(find.byIcon(Icons.catching_pokemon), findsOneWidget);
  });

  testWidgets('si altura y peso faltan (0), muestra un guion', (tester) async {
    await pumpPage(tester);

    repository.pokemonController.add(
      const Pokemon(
        id: 1,
        name: 'bulbasaur',
        nationalDexNumber: 1,
        generationId: 1,
        height: 0,
        weight: 0,
        types: [PokemonType(id: 12, name: 'grass')],
      ),
    );
    await tester.pump();

    // Un guion por cada medida que falta.
    expect(find.text('—'), findsNWidgets(2));
    expect(find.text('0,0 m'), findsNothing);
  });

  testWidgets('si el Pokémon no está guardado, muestra "no encontrado"', (
    tester,
  ) async {
    await pumpPage(tester);

    repository.pokemonController.add(null);
    await tester.pump();

    expect(find.text('Pokémon no encontrado'), findsOneWidget);
    expect(find.text('Volver'), findsOneWidget);
  });
}
