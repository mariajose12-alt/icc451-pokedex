import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/settings/presentation/widgets/walking_pokemon.dart';

import '../../helpers/fake_saved_pokemon_repository.dart';

void main() {
  testWidgets('sin sprites guardados no muestra nada y no falla', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WalkingPokemon(repository: FakeSavedPokemonRepository()),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(CachedNetworkImage), findsNothing);
  });

  testWidgets('con texto muy grande no ocupa espacio', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: WalkingPokemon(
            repository: FakeSavedPokemonRepository(
              sprites: ['https://x/1.png'],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.getSize(find.byType(WalkingPokemon)).height, 0);
  });
}
