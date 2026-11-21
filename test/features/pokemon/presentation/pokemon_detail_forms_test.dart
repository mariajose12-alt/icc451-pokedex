import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_extras.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_form.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_type.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_extras_cubit.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_header.dart';
import 'package:pokedex/l10n/app_localizations.dart';

import '../../../helpers/fake_pokemon_detail_repository.dart';

const Pokemon _charizard = Pokemon(
  id: 6,
  name: 'charizard',
  nationalDexNumber: 6,
  generationId: 1,
  height: 17,
  weight: 905,
  types: [
    PokemonType(id: 10, name: 'fire'),
    PokemonType(id: 3, name: 'flying'),
  ],
  stats: [],
);

const PokemonForm _normal = PokemonForm(
  id: 6,
  name: 'charizard',
  isDefault: true,
  typeIds: [10, 3],
  spriteUrl: null,
  shinySpriteUrl: null,
  artworkUrl: null,
  shinyArtworkUrl: null,
);

const PokemonForm _megaX = PokemonForm(
  id: 10034,
  name: 'charizard-mega-x',
  isDefault: false,
  typeIds: [10, 16],
  spriteUrl: null,
  shinySpriteUrl: null,
  artworkUrl: null,
  shinyArtworkUrl: null,
);

void main() {
  late FakePokemonDetailRepository repository;

  setUp(() {
    repository = FakePokemonDetailRepository();
  });

  tearDown(() async {
    await repository.extrasController.close();
  });

  Future<void> pumpHeader(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BlocProvider(
            create: (_) =>
                PokemonExtrasCubit(repository: repository, pokemonId: 6),
            child: const SingleChildScrollView(
              child: PokemonDetailHeader(pokemon: _charizard, hasExtras: true),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('sin formas el botón de formas no abre nada', (tester) async {
    await pumpHeader(tester);

    await tester.tap(find.byIcon(Icons.layers));
    await tester.pumpAndSettle();

    expect(find.text('Forma'), findsNothing);
  });

  testWidgets('elegir Mega X cambia el número de la cabecera', (tester) async {
    await pumpHeader(tester);

    repository.extrasController.add(
      const PokemonExtras(downloaded: true, forms: [_normal, _megaX]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.layers));
    await tester.pumpAndSettle();

    // La hoja muestra las dos formas.
    expect(find.text('Forma'), findsOneWidget);
    expect(find.text('Normal'), findsOneWidget);
    expect(find.text('Mega X'), findsOneWidget);

    await tester.tap(find.text('Mega X'));
    await tester.pumpAndSettle();

    // La hoja se cierra y la cabecera dice la forma.
    expect(find.text('Forma'), findsNothing);
    expect(find.textContaining('· Mega X', findRichText: true), findsOneWidget);
  });

  testWidgets('volver a Normal quita el nombre de la forma', (tester) async {
    await pumpHeader(tester);

    repository.extrasController.add(
      const PokemonExtras(downloaded: true, forms: [_normal, _megaX]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.layers));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mega X'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.layers));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Normal'));
    await tester.pumpAndSettle();

    expect(find.textContaining('· Mega X', findRichText: true), findsNothing);
  });
}
