import 'package:pokedex/core/database/daos/detalle_dao.dart';
import 'package:pokedex/features/pokemon/domain/entities/evolution_stage.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_ability.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_extras.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_form.dart';

/// Convierte las filas de la base en entidades del dominio.
extension PokemonExtrasRowsMapper on PokemonExtrasRows {
  PokemonExtras toDomain() {
    final abilityList = <PokemonAbility>[];
    for (final item in abilities) {
      abilityList.add(
        PokemonAbility(
          id: item.ability.id,
          name: item.ability.name,
          nameEs: item.ability.nameEs,
          nameEn: item.ability.nameEn,
          effectSummary: item.ability.effectSummary,
          isHidden: item.isHidden,
        ),
      );
    }

    final stages = <EvolutionStage>[];
    for (final node in evolutionNodes) {
      stages.add(
        EvolutionStage(
          speciesId: node.speciesId,
          name: node.speciesName,
          fromSpeciesId: node.fromSpeciesId,
          trigger: node.trigger,
          minLevel: node.minLevel,
          minHappiness: node.minHappiness,
          timeOfDay: node.timeOfDay,
          itemName: node.itemName,
        ),
      );
    }

    final formList = <PokemonForm>[];
    for (final form in forms) {
      formList.add(
        PokemonForm(
          id: form.id,
          name: form.name,
          isDefault: form.isDefault,
          typeIds: formTypeIds[form.id] ?? const <int>[],
          spriteUrl: form.spriteUrl,
          shinySpriteUrl: form.shinySpriteUrl,
          artworkUrl: form.artworkUrl,
          shinyArtworkUrl: form.shinyArtworkUrl,
        ),
      );
    }

    return PokemonExtras(
      downloaded: downloaded,
      abilities: abilityList,
      eggGroups: eggGroups,
      evolution: stages,
      forms: formList,
    );
  }
}
