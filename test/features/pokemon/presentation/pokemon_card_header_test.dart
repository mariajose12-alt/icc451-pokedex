import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_stat.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_type.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_header.dart';
import 'package:pokedex/l10n/app_localizations.dart';

const _pokemon = Pokemon(
  id: 1,
  name: 'bulbasaur',
  nationalDexNumber: 1,
  generationId: 1,
  height: 7,
  weight: 69,
  types: [PokemonType(id: 12, name: 'grass')],
  stats: [PokemonStat(statId: 1, baseStat: 45)],
);

void main() {
  testWidgets('el botón Compartir abre la Pokémon Card', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: PokemonDetailHeader(pokemon: _pokemon),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Compartir'));
    await tester.pumpAndSettle();

    expect(find.text('Compartir carta'), findsOneWidget);
    expect(find.text('POKÉDEX NACIONAL'), findsOneWidget);
    expect(find.text('Bulbasaur'), findsWidgets);
  });
}
