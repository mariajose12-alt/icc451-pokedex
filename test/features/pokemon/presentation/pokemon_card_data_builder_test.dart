import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/domain/entities/damage_matchups.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_ability.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_extras.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_stat.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_type.dart';
import 'package:pokedex/features/pokemon/presentation/share/pokemon_card_data_builder.dart';
import 'package:pokedex/l10n/app_localizations_en.dart';
import 'package:pokedex/l10n/app_localizations_es.dart';

const _bulbasaur = Pokemon(
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

const _extras = PokemonExtras(
  downloaded: true,
  abilities: [
    PokemonAbility(
      id: 65,
      name: 'overgrow',
      nameEs: 'Espesura',
      nameEn: 'Overgrow',
      effectSummary: null,
      isHidden: false,
    ),
    PokemonAbility(
      id: 34,
      name: 'chlorophyll',
      nameEs: 'Clorofila',
      nameEn: 'Chlorophyll',
      effectSummary: null,
      isHidden: true,
    ),
  ],
);

const _names = {
  10: 'fire',
  3: 'flying',
  15: 'ice',
  14: 'psychic',
  5: 'ground',
  12: 'grass',
  11: 'water',
};

const _matchups = DamageMatchups(
  weaknesses: [
    TypeMatchup(typeId: 10, multiplierPercent: 200),
    TypeMatchup(typeId: 3, multiplierPercent: 200),
    TypeMatchup(typeId: 15, multiplierPercent: 200),
    TypeMatchup(typeId: 14, multiplierPercent: 200),
  ],
  resistances: [
    TypeMatchup(typeId: 12, multiplierPercent: 25),
    TypeMatchup(typeId: 11, multiplierPercent: 50),
  ],
  immunities: [TypeMatchup(typeId: 5, multiplierPercent: 0)],
);

void main() {
  test('trae identidad, stats en orden y total', () {
    final data = buildPokemonCardData(
      pokemon: _bulbasaur,
      extras: _extras,
      matchups: _matchups,
      typeNamesById: _names,
      typeNames: const ['grass', 'poison'],
      imageUrl: 'https://img/1.png',
      name: 'Bulbasaur',
      l10n: AppLocalizationsEs(),
      languageCode: 'es',
    );

    expect(data.name, 'Bulbasaur');
    expect(data.nationalDexNumber, 1);
    expect(data.typeNames, ['grass', 'poison']);
    expect(
      [for (final s in data.stats) s.label],
      ['HP', 'ATK', 'DEF', 'SPA', 'SPD', 'SPE'],
    );
    expect([for (final s in data.stats) s.value], [45, 49, 49, 65, 65, 45]);
    expect(data.total, 318);
    expect(data.imageUrl, 'https://img/1.png');
  });

  test('el color de la carta es el del tipo principal', () {
    final data = buildPokemonCardData(
      pokemon: _bulbasaur,
      extras: _extras,
      matchups: _matchups,
      typeNamesById: _names,
      typeNames: const ['grass', 'poison'],
      imageUrl: null,
      name: 'Bulbasaur',
      l10n: AppLocalizationsEs(),
      languageCode: 'es',
    );

    expect(data.accentColor, const Color(0xFF78C850));
  });

  test('altura y peso salen con la coma o el punto del idioma', () {
    final es = buildPokemonCardData(
      pokemon: _bulbasaur,
      extras: _extras,
      matchups: _matchups,
      typeNamesById: _names,
      typeNames: const ['grass'],
      imageUrl: null,
      name: 'Bulbasaur',
      l10n: AppLocalizationsEs(),
      languageCode: 'es',
    );
    final en = buildPokemonCardData(
      pokemon: _bulbasaur,
      extras: _extras,
      matchups: _matchups,
      typeNamesById: _names,
      typeNames: const ['grass'],
      imageUrl: null,
      name: 'Bulbasaur',
      l10n: AppLocalizationsEn(),
      languageCode: 'en',
    );

    expect(es.heightWeight, '0,7 m · 6,9 kg');
    expect(en.heightWeight, '0.7 m · 6.9 kg');
  });

  test('las habilidades van en el idioma y marcan la oculta', () {
    final data = buildPokemonCardData(
      pokemon: _bulbasaur,
      extras: _extras,
      matchups: _matchups,
      typeNamesById: _names,
      typeNames: const ['grass'],
      imageUrl: null,
      name: 'Bulbasaur',
      l10n: AppLocalizationsEs(),
      languageCode: 'es',
    );

    expect(data.abilities, 'Espesura · Clorofila (oculta)');
  });

  test('débil contra: los primeros cuatro con su multiplicador', () {
    final data = buildPokemonCardData(
      pokemon: _bulbasaur,
      extras: _extras,
      matchups: _matchups,
      typeNamesById: _names,
      typeNames: const ['grass'],
      imageUrl: null,
      name: 'Bulbasaur',
      l10n: AppLocalizationsEs(),
      languageCode: 'es',
    );

    expect(data.weakTo, 'Fire ×2, Flying ×2, Ice ×2, Psychic ×2');
  });

  test('resiste: las inmunidades van primero', () {
    final data = buildPokemonCardData(
      pokemon: _bulbasaur,
      extras: _extras,
      matchups: _matchups,
      typeNamesById: _names,
      typeNames: const ['grass'],
      imageUrl: null,
      name: 'Bulbasaur',
      l10n: AppLocalizationsEs(),
      languageCode: 'es',
    );

    expect(data.resists, 'Ground ×0, Grass ×¼, Water ×½');
  });

  test('sin datos muestra «—» y no falla', () {
    final data = buildPokemonCardData(
      pokemon: const Pokemon(
        id: 1,
        name: 'x',
        nationalDexNumber: 1,
        generationId: 1,
        height: 0,
        weight: 0,
        types: [],
      ),
      extras: PokemonExtras.empty,
      matchups: DamageMatchups.empty,
      typeNamesById: const {},
      typeNames: const [],
      imageUrl: null,
      name: 'X',
      l10n: AppLocalizationsEs(),
      languageCode: 'es',
    );

    expect(data.stats, isEmpty);
    expect(data.total, 0);
    expect(data.heightWeight, '— · —');
    expect(data.abilities, '—');
    expect(data.weakTo, '—');
    expect(data.resists, '—');
  });
}
