import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_ability.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_extras.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_stat.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_type.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_content.dart';
import 'package:pokedex/l10n/app_localizations.dart';

import '../../../helpers/fake_pokemon_detail_repository.dart';

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

const PokemonExtras _extras = PokemonExtras(
  downloaded: true,
  abilities: [
    PokemonAbility(
      id: 65,
      name: 'overgrow',
      nameEs: 'Espesura',
      nameEn: 'Overgrow',
      effectSummary: 'Boosts grass moves.',
      isHidden: false,
    ),
    PokemonAbility(
      id: 34,
      name: 'chlorophyll',
      nameEs: null,
      nameEn: 'Chlorophyll',
      effectSummary: null,
      isHidden: true,
    ),
  ],
  eggGroups: ['monster', 'plant'],
);

Widget _app(Widget child, {String language = 'es'}) {
  return MaterialApp(
    locale: Locale(language),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  late FakePokemonDetailRepository repository;

  setUp(() {
    repository = FakePokemonDetailRepository();
  });

  tearDown(() async {
    await repository.extrasController.close();
  });

  Future<void> pumpContent(
    WidgetTester tester, {
    String language = 'es',
    double textScale = 1,
  }) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: _app(
          PokemonDetailContent(
            pokemon: _bulbasaur,
            detailRepository: repository,
          ),
          language: language,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('sin descargar muestra el aviso y no los egg groups', (
    tester,
  ) async {
    await pumpContent(tester);

    expect(find.text('Habilidades'), findsOneWidget);
    expect(
      find.text('Estos datos se descargan al abrir el Pokémon con conexión'),
      findsOneWidget,
    );
    expect(find.text('Grupos huevo'), findsNothing);
  });

  testWidgets('con datos muestra habilidades, «Oculta» y el efecto', (
    tester,
  ) async {
    await pumpContent(tester);

    repository.extrasController.add(_extras);
    await tester.pumpAndSettle();

    expect(find.text('Espesura'), findsOneWidget);
    expect(find.text('Boosts grass moves.'), findsOneWidget);
    // Sin nombre en español usa el inglés.
    expect(find.text('Chlorophyll'), findsOneWidget);
    expect(find.text('Oculta'), findsOneWidget);
    // Sin efecto: texto de respaldo.
    expect(find.text('Sin descripción'), findsOneWidget);
    // El efecto solo existe en inglés y la pantalla lo avisa.
    expect(find.text('Las descripciones están en inglés'), findsOneWidget);
    expect(
      find.text('Estos datos se descargan al abrir el Pokémon con conexión'),
      findsNothing,
    );
  });

  testWidgets('muestra los egg groups traducidos', (tester) async {
    await pumpContent(tester);

    repository.extrasController.add(_extras);
    await tester.pumpAndSettle();

    expect(find.text('Grupos huevo'), findsOneWidget);
    expect(find.text('Monstruo · Planta'), findsOneWidget);
  });

  testWidgets('en inglés usa los nombres en inglés y no avisa del idioma', (
    tester,
  ) async {
    await pumpContent(tester, language: 'en');

    repository.extrasController.add(_extras);
    await tester.pumpAndSettle();

    expect(find.text('Abilities'), findsOneWidget);
    expect(find.text('Overgrow'), findsOneWidget);
    expect(find.text('Hidden'), findsOneWidget);
    expect(find.text('Egg groups'), findsOneWidget);
    expect(find.text('Monster · Grass'), findsOneWidget);
    expect(find.text('Descriptions are in English'), findsNothing);
  });

  testWidgets('con texto al 200 % no se desborda', (tester) async {
    await pumpContent(tester, textScale: 2);

    repository.extrasController.add(_extras);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('sin repositorio no se muestran habilidades ni egg groups', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const PokemonDetailContent(pokemon: _bulbasaur)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Habilidades'), findsNothing);
    expect(find.text('Grupos huevo'), findsNothing);
  });
}
