import 'package:intl/intl.dart';
import 'package:pokedex/core/theme/type_colors.dart';
import 'package:pokedex/features/pokemon/domain/entities/damage_matchups.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_extras.dart';
import 'package:pokedex/features/pokemon/presentation/share/pokemon_card_data.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_matchups.dart'
    show matchupMultiplierLabel;
import 'package:pokedex/l10n/app_localizations.dart';

// Etiquetas cortas, en el orden de statId (1 a 6).
const _statLabels = ['HP', 'ATK', 'DEF', 'SPA', 'SPD', 'SPE'];

// Cuántos tipos se listan como máximo en «Débil contra» y «Resiste».
const _maxListed = 4;

/// Arma los datos de la Pokémon Card (RF-COM-01) a partir de las entidades.
/// Es una función pura: no lee la base ni toca widgets, así se prueba sola.
PokemonCardData buildPokemonCardData({
  required Pokemon pokemon,
  required PokemonExtras extras,
  required DamageMatchups matchups,
  required Map<int, String> typeNamesById,
  required List<String> typeNames,
  required String? imageUrl,
  required String name,
  required AppLocalizations l10n,
  required String languageCode,
}) {
  final format = NumberFormat('0.0', languageCode);

  final stats = <PokemonCardStat>[
    for (final stat in pokemon.stats)
      if (stat.statId >= 1 && stat.statId <= _statLabels.length)
        PokemonCardStat(
          label: _statLabels[stat.statId - 1],
          value: stat.baseStat,
        ),
  ];

  // En la base, altura y peso faltantes se guardan como 0: se muestra «—».
  final height = pokemon.height <= 0
      ? l10n.cardNoData
      : l10n.detailHeightValue(format.format(pokemon.height / 10));
  final weight = pokemon.weight <= 0
      ? l10n.cardNoData
      : l10n.detailWeightValue(format.format(pokemon.weight / 10));

  final abilityNames = <String>[
    for (final ability in extras.abilities)
      ability.isHidden
          ? l10n.cardAbilityHidden(ability.displayName(languageCode))
          : ability.displayName(languageCode),
  ];

  final accent =
      PokemonTypeColors.byName[typeNames.isEmpty ? '' : typeNames.first] ??
      PokemonTypeColors.fallback;

  return PokemonCardData(
    name: name,
    nationalDexNumber: pokemon.nationalDexNumber,
    typeNames: typeNames,
    accentColor: accent.background,
    stats: stats,
    total: pokemon.totalStats,
    heightWeight: '$height · $weight',
    abilities: abilityNames.isEmpty
        ? l10n.cardNoData
        : abilityNames.join(' · '),
    weakTo: _matchupText(matchups.weaknesses, typeNamesById, l10n.cardNoData),
    // Las inmunidades van primero: son lo más fuerte que se puede resistir.
    resists: _matchupText(
      [...matchups.immunities, ...matchups.resistances],
      typeNamesById,
      l10n.cardNoData,
    ),
    imageUrl: imageUrl,
  );
}

/// «Fire ×2, Flying ×2»: los primeros tipos de la lista, con su multiplicador.
String _matchupText(
  List<TypeMatchup> matchups,
  Map<int, String> typeNamesById,
  String empty,
) {
  final parts = <String>[];
  for (final matchup in matchups.take(_maxListed)) {
    final name = typeNamesById[matchup.typeId];
    if (name == null || name.isEmpty) {
      continue;
    }
    final capitalized = '${name[0].toUpperCase()}${name.substring(1)}';
    parts.add(
      '$capitalized ${matchupMultiplierLabel(matchup.multiplierPercent)}',
    );
  }
  return parts.isEmpty ? empty : parts.join(', ');
}
