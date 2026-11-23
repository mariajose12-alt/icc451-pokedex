import 'package:drift/drift.dart' show Value;
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/core/database/daos/detalle_dao.dart';
import 'package:pokedex/features/pokemon/data/models/pokemon_companion_mapper.dart';
import 'package:pokedex/features/pokemon/data/models/pokemon_detail_dto.dart';

/// Convierte el detalle de PokeAPI en las filas que guarda [DetalleDao].
PokemonDetailRows detailToRows(PokemonDetailDto dto, DateTime now) {
  final id = dto.base.id;

  // Datos base: igual que una página de una sola fila del catálogo.
  final base = pageToCompanions([dto.base], now);

  // Habilidades y su relación con el Pokémon.
  final abilities = <AbilitiesCompanion>[];
  final pokemonAbilities = <PokemonAbilitiesCompanion>[];
  for (final ability in dto.abilities) {
    abilities.add(
      AbilitiesCompanion.insert(
        id: Value(ability.id),
        name: ability.name,
        nameEs: Value(ability.nameEs),
        nameEn: Value(ability.nameEn),
        // Máximo 160 caracteres (RF-DET-03).
        effectSummary: Value(AbilityDto.summarize(ability.effectEn)),
      ),
    );
    pokemonAbilities.add(
      PokemonAbilitiesCompanion.insert(
        pokemonId: id,
        abilityId: ability.id,
        isHidden: Value(ability.isHidden),
      ),
    );
  }

  // Egg groups.
  final eggGroups = <PokemonEggGroupsCompanion>[];
  for (final name in dto.eggGroups) {
    eggGroups.add(
      PokemonEggGroupsCompanion.insert(pokemonId: id, eggGroup: name),
    );
  }

  // Cadena evolutiva (una fila por especie).
  final chain = dto.evolutionChain;
  final evolutionNodes = <EvolutionNodesCompanion>[];
  if (chain != null) {
    for (final node in chain.nodes) {
      evolutionNodes.add(
        EvolutionNodesCompanion.insert(
          chainId: chain.id,
          speciesId: node.speciesId,
          speciesName: node.name,
          fromSpeciesId: Value(node.fromSpeciesId),
          trigger: Value(node.trigger),
          minLevel: Value(node.minLevel),
          minHappiness: Value(node.minHappiness),
          timeOfDay: Value(node.timeOfDay),
          itemName: Value(node.itemName),
        ),
      );
    }
  }

  // Formas y sus tipos.
  final forms = <PokemonFormsCompanion>[];
  final formTypes = <PokemonFormTypesCompanion>[];
  for (final form in dto.forms) {
    forms.add(
      PokemonFormsCompanion.insert(
        id: Value(form.id),
        speciesId: id,
        name: form.name,
        isDefault: form.isDefault,
        spriteUrl: Value(form.spriteUrl),
        shinySpriteUrl: Value(form.shinySpriteUrl),
        artworkUrl: Value(form.artworkUrl),
        shinyArtworkUrl: Value(form.shinyArtworkUrl),
      ),
    );
    for (final type in form.types) {
      formTypes.add(
        PokemonFormTypesCompanion.insert(
          formId: form.id,
          typeId: type.typeId,
          slot: type.slot,
        ),
      );
    }
  }

  // Movimientos. Un mismo movimiento o grupo de versión aparece en muchas
  // filas: en los catálogos se guarda una sola vez (por eso los mapas).
  final movesById = <int, MovesCompanion>{};
  final groupsById = <int, VersionGroupsCompanion>{};
  final pokemonMoves = <PokemonMovesCompanion>[];
  for (final move in dto.moves) {
    movesById[move.moveId] = MovesCompanion.insert(
      id: Value(move.moveId),
      name: move.moveName,
    );
    groupsById[move.versionGroupId] = VersionGroupsCompanion.insert(
      id: Value(move.versionGroupId),
      name: move.versionGroupName,
    );
    pokemonMoves.add(
      PokemonMovesCompanion.insert(
        pokemonId: id,
        versionGroupId: move.versionGroupId,
        learnMethodId: move.learnMethodId,
        moveId: move.moveId,
        level: Value(move.level),
      ),
    );
  }

  return PokemonDetailRows(
    pokemonId: id,
    types: base.types,
    pokemons: base.pokemons,
    pokemonTypes: base.pokemonTypes,
    stats: base.stats,
    abilities: abilities,
    pokemonAbilities: pokemonAbilities,
    eggGroups: eggGroups,
    evolutionChainId: chain?.id,
    evolutionNodes: evolutionNodes,
    forms: forms,
    formTypes: formTypes,
    moves: movesById.values.toList(),
    versionGroups: groupsById.values.toList(),
    pokemonMoves: pokemonMoves,
  );
}
