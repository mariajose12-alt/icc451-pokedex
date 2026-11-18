import 'package:pokedex/l10n/app_localizations.dart';
import 'package:pokedex/features/pokemon/domain/entities/evolution_stage.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_form.dart';

/// Convierte un identificador de PokeAPI en texto legible:
/// 'swords-dance' -> 'Swords Dance'.
String prettifySlug(String slug) {
  final words = slug.split('-');
  final result = <String>[];
  for (final word in words) {
    if (word.isEmpty) {
      result.add(word);
    } else {
      result.add(word[0].toUpperCase() + word.substring(1));
    }
  }
  return result.join(' ');
}

/// Nombre de un egg group en el idioma de la app. PokeAPI solo manda el
/// identificador; si llega uno que no conocemos se muestra formateado.
String eggGroupLabel(AppLocalizations l10n, String slug) {
  return switch (slug) {
    'monster' => l10n.eggGroupMonster,
    'water1' => l10n.eggGroupWater1,
    'water2' => l10n.eggGroupWater2,
    'water3' => l10n.eggGroupWater3,
    'bug' => l10n.eggGroupBug,
    'flying' => l10n.eggGroupFlying,
    'ground' => l10n.eggGroupField,
    'fairy' => l10n.eggGroupFairy,
    'plant' => l10n.eggGroupGrass,
    'humanshape' => l10n.eggGroupHumanLike,
    'mineral' => l10n.eggGroupMineral,
    'indeterminate' => l10n.eggGroupAmorphous,
    'ditto' => l10n.eggGroupDitto,
    'dragon' => l10n.eggGroupDragon,
    'no-eggs' => l10n.eggGroupUndiscovered,
    _ => prettifySlug(slug),
  };
}

/// Texto de la condición para evolucionar hasta [stage]:
/// «Nivel 16», «Usar Fire Stone», «Amistad alta · de noche»...
String evolutionTriggerLabel(AppLocalizations l10n, EvolutionStage stage) {
  final item = stage.itemName;
  final level = stage.minLevel;

  final base = switch (stage.trigger) {
    'level-up' =>
      level != null
          ? l10n.evolutionTriggerLevel(level)
          : stage.minHappiness != null
          ? l10n.evolutionTriggerFriendship
          : l10n.evolutionTriggerLevelUp,
    'trade' => l10n.evolutionTriggerTrade,
    'use-item' =>
      item == null
          ? l10n.evolutionTriggerItemGeneric
          : l10n.evolutionTriggerItem(prettifySlug(item)),
    null => l10n.evolutionTriggerUnknown,
    final other => prettifySlug(other),
  };

  final time = switch (stage.timeOfDay) {
    null => null,
    'day' => l10n.evolutionTimeDay,
    'night' => l10n.evolutionTimeNight,
    'dusk' => l10n.evolutionTimeDusk,
    final other => prettifySlug(other),
  };

  return time == null ? base : '$base · $time';
}

/// Nombre de una forma para mostrar: 'charizard-mega-x' → «Mega X»,
/// 'rattata-alola' → «Alola». La forma normal se llama «Normal».
String formLabel(AppLocalizations l10n, String pokemonName, PokemonForm form) {
  if (form.isDefault || form.name == pokemonName) {
    return l10n.detailFormNormal;
  }

  // Se quita el nombre de la especie del principio.
  final prefix = '$pokemonName-';
  final suffix = form.name.startsWith(prefix)
      ? form.name.substring(prefix.length)
      : form.name;

  return switch (suffix) {
    'gmax' => 'Gigamax',
    _ => prettifySlug(suffix),
  };
}
