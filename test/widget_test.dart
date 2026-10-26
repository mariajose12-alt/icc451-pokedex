import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_type.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_card.dart';

void main() {
  testWidgets(
    'PokemonCard muestra número, nombre y tipos, y responde al toque',
    (tester) async {
      var tocado = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PokemonCard(
              pokemon: const Pokemon(
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
              ),
              onTap: () {
                tocado = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('#001'), findsOneWidget);
      expect(find.text('Bulbasaur'), findsOneWidget);
      expect(find.text('Grass'), findsOneWidget);
      expect(find.text('Poison'), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      expect(tocado, isTrue);
    },
  );
}
