import 'package:pokedex/features/pokemon/data/models/pokemon_dto.dart';

/// Todo el detalle de un Pokémon tal como lo devuelve PokeAPI en una llamada.
class PokemonDetailDto {
  const PokemonDetailDto({
    required this.base,
    required this.abilities,
    required this.eggGroups,
    required this.evolutionChain,
    required this.forms,
    required this.moves,
  });

  /// Los mismos datos que el catálogo (nombre, tipos, stats, imágenes).
  final PokemonDto base;
  final List<AbilityDto> abilities;

  /// Identificadores de PokeAPI: 'monster', 'plant'...
  final List<String> eggGroups;

  /// Null si PokeAPI no manda cadena evolutiva.
  final EvolutionChainDto? evolutionChain;
  final List<PokemonFormDto> forms;
  final List<PokemonMoveDto> moves;

  factory PokemonDetailDto.fromJson(Map<String, dynamic> json) {
    // Base: debe haber exactamente un Pokémon. Si no, el id no existe.
    final baseList = json['base'] as List<dynamic>;
    if (baseList.isEmpty) {
      throw const FormatException('No existe un Pokémon con ese id');
    }
    final baseJson = baseList.first as Map<String, dynamic>;

    // Habilidades (están dentro de base).
    final abilities = <AbilityDto>[];
    final abilitiesJson =
        baseJson['pokemonabilities'] as List<dynamic>? ?? const <dynamic>[];
    for (final item in abilitiesJson) {
      abilities.add(AbilityDto.fromJson(item as Map<String, dynamic>));
    }

    // Especie: egg groups y cadena evolutiva.
    final eggGroups = <String>[];
    EvolutionChainDto? chain;
    final speciesList = json['species'] as List<dynamic>? ?? const <dynamic>[];
    if (speciesList.isNotEmpty) {
      final species = speciesList.first as Map<String, dynamic>;

      final eggJson =
          species['pokemonegggroups'] as List<dynamic>? ?? const <dynamic>[];
      for (final item in eggJson) {
        final group = (item as Map<String, dynamic>)['egggroup'];
        eggGroups.add((group as Map<String, dynamic>)['name'] as String);
      }

      final chainJson = species['evolutionchain'] as Map<String, dynamic>?;
      if (chainJson != null) {
        chain = EvolutionChainDto.fromJson(chainJson);
      }
    }

    // Formas.
    final forms = <PokemonFormDto>[];
    final formsJson = json['forms'] as List<dynamic>? ?? const <dynamic>[];
    for (final item in formsJson) {
      forms.add(PokemonFormDto.fromJson(item as Map<String, dynamic>));
    }

    // Movimientos.
    final moves = <PokemonMoveDto>[];
    final movesJson = json['moves'] as List<dynamic>? ?? const <dynamic>[];
    for (final item in movesJson) {
      moves.add(PokemonMoveDto.fromJson(item as Map<String, dynamic>));
    }

    return PokemonDetailDto(
      base: PokemonDto.fromJson(baseJson),
      abilities: abilities,
      eggGroups: eggGroups,
      evolutionChain: chain,
      forms: forms,
      moves: moves,
    );
  }
}

/// Una habilidad de un Pokémon.
class AbilityDto {
  const AbilityDto({
    required this.id,
    required this.name,
    required this.nameEs,
    required this.nameEn,
    required this.effectEn,
    required this.isHidden,
  });

  final int id;

  /// Identificador de PokeAPI, por ejemplo 'overgrow'.
  final String name;
  final String? nameEs;
  final String? nameEn;

  /// Efecto corto en inglés, tal como llega (el español no existe).
  final String? effectEn;
  final bool isHidden;

  /// Idiomas de PokeAPI.
  static const int _spanish = 7;
  static const int _english = 9;

  /// Máximo de caracteres del efecto resumido (RF-DET-03).
  static const int maxEffectLength = 160;

  factory AbilityDto.fromJson(Map<String, dynamic> json) {
    final ability = json['ability'] as Map<String, dynamic>;

    String? nameEs;
    String? nameEn;
    final names =
        ability['abilitynames'] as List<dynamic>? ?? const <dynamic>[];
    for (final item in names) {
      final row = item as Map<String, dynamic>;
      final name = row['name'] as String;
      switch (row['language_id'] as int) {
        case _spanish:
          nameEs = name;
        case _english:
          nameEn = name;
      }
    }

    String? effect;
    final effects =
        ability['abilityeffecttexts'] as List<dynamic>? ?? const <dynamic>[];
    if (effects.isNotEmpty) {
      effect =
          (effects.first as Map<String, dynamic>)['short_effect'] as String?;
    }

    return AbilityDto(
      id: ability['id'] as int,
      name: ability['name'] as String,
      nameEs: nameEs,
      nameEn: nameEn,
      effectEn: effect,
      isHidden: json['is_hidden'] as bool,
    );
  }

  /// Efecto resumido: máximo [maxEffectLength] caracteres, contando el «…».
  /// Si el texto es más largo, corta en el último espacio que cabe para no
  /// partir una palabra. Devuelve null si no hay texto (RF-DET-03).
  static String? summarize(String? text, {int maxLength = maxEffectLength}) {
    if (text == null) {
      return null;
    }

    // PokeAPI a veces trae saltos de línea: se dejan como espacios.
    final clean = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (clean.isEmpty) {
      return null;
    }
    if (clean.length <= maxLength) {
      return clean;
    }

    // Se deja un carácter libre para la «…».
    final cut = clean.substring(0, maxLength - 1);
    final lastSpace = cut.lastIndexOf(' ');
    final words = lastSpace > 0 ? cut.substring(0, lastSpace) : cut;
    return '${words.trimRight()}…';
  }
}

/// Una cadena evolutiva completa (todas sus especies).
class EvolutionChainDto {
  const EvolutionChainDto({required this.id, required this.nodes});

  final int id;
  final List<EvolutionNodeDto> nodes;

  factory EvolutionChainDto.fromJson(Map<String, dynamic> json) {
    final nodes = <EvolutionNodeDto>[];
    final species = json['pokemonspecies'] as List<dynamic>;
    for (final item in species) {
      nodes.add(EvolutionNodeDto.fromJson(item as Map<String, dynamic>));
    }
    return EvolutionChainDto(id: json['id'] as int, nodes: nodes);
  }
}

/// Una especie dentro de una cadena, con la condición para evolucionar hasta
/// ella desde la anterior (RF-DET-04).
class EvolutionNodeDto {
  const EvolutionNodeDto({
    required this.speciesId,
    required this.name,
    required this.fromSpeciesId,
    required this.trigger,
    required this.minLevel,
    required this.minHappiness,
    required this.timeOfDay,
    required this.itemName,
  });

  final int speciesId;
  final String name;

  /// Null en la primera especie de la cadena.
  final int? fromSpeciesId;

  /// 'level-up', 'trade', 'use-item'... Null en la primera especie.
  final String? trigger;
  final int? minLevel;
  final int? minHappiness;

  /// Null cuando no hay condición de hora.
  final String? timeOfDay;
  final String? itemName;

  factory EvolutionNodeDto.fromJson(Map<String, dynamic> json) {
    // Una especie puede tener varias condiciones; se toma la primera, que es
    // el «trigger principal» que pide RF-DET-04.
    final evolutions =
        json['pokemonevolutions'] as List<dynamic>? ?? const <dynamic>[];
    final main = evolutions.isEmpty
        ? null
        : evolutions.first as Map<String, dynamic>;

    // PokeAPI manda '' cuando no hay hora: se guarda como null.
    final time = main?['time_of_day'] as String?;

    final trigger = main?['evolutiontrigger'] as Map<String, dynamic>?;
    final item = main?['item'] as Map<String, dynamic>?;

    return EvolutionNodeDto(
      speciesId: json['id'] as int,
      name: json['name'] as String,
      fromSpeciesId: json['evolves_from_species_id'] as int?,
      trigger: trigger?['name'] as String?,
      minLevel: main?['min_level'] as int?,
      minHappiness: main?['min_happiness'] as int?,
      timeOfDay: (time == null || time.isEmpty) ? null : time,
      itemName: item?['name'] as String?,
    );
  }
}

/// Una forma de la especie (la normal, Alola, Galar...), con sus imágenes.
class PokemonFormDto {
  const PokemonFormDto({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.types,
    required this.spriteUrl,
    required this.shinySpriteUrl,
    required this.artworkUrl,
    required this.shinyArtworkUrl,
  });

  /// Id del Pokémon-forma en PokeAPI (Rattata de Alola = 10091).
  final int id;
  final String name;
  final bool isDefault;
  final List<FormTypeDto> types;
  final String? spriteUrl;
  final String? shinySpriteUrl;
  final String? artworkUrl;
  final String? shinyArtworkUrl;

  factory PokemonFormDto.fromJson(Map<String, dynamic> json) {
    final types = <FormTypeDto>[];
    final typesJson =
        json['pokemontypes'] as List<dynamic>? ?? const <dynamic>[];
    for (final item in typesJson) {
      types.add(FormTypeDto.fromJson(item as Map<String, dynamic>));
    }

    // pokemonsprites es una lista; la primera fila trae las cuatro URL.
    final spritesList =
        json['pokemonsprites'] as List<dynamic>? ?? const <dynamic>[];
    final sprites = spritesList.isEmpty
        ? const <String, dynamic>{}
        : spritesList.first as Map<String, dynamic>;

    return PokemonFormDto(
      id: json['id'] as int,
      name: json['name'] as String,
      isDefault: json['is_default'] as bool,
      types: types,
      spriteUrl: sprites['sprite'] as String?,
      shinySpriteUrl: sprites['shiny'] as String?,
      artworkUrl: sprites['artwork'] as String?,
      shinyArtworkUrl: sprites['artwork_shiny'] as String?,
    );
  }
}

/// Tipo de una forma.
class FormTypeDto {
  const FormTypeDto({required this.typeId, required this.slot});

  final int typeId;
  final int slot;

  factory FormTypeDto.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as Map<String, dynamic>;
    return FormTypeDto(typeId: type['id'] as int, slot: json['slot'] as int);
  }
}

/// Un movimiento que el Pokémon aprende (RF-DET-05).
class PokemonMoveDto {
  const PokemonMoveDto({
    required this.moveId,
    required this.moveName,
    required this.learnMethodId,
    required this.versionGroupId,
    required this.versionGroupName,
    required this.level,
  });

  final int moveId;
  final String moveName;

  /// 1 level-up, 2 egg, 3 tutor, 4 machine.
  final int learnMethodId;
  final int versionGroupId;
  final String versionGroupName;

  /// 0 cuando el método no usa nivel.
  final int level;

  factory PokemonMoveDto.fromJson(Map<String, dynamic> json) {
    final move = json['move'] as Map<String, dynamic>;
    final method = json['movelearnmethod'] as Map<String, dynamic>;
    final group = json['versiongroup'] as Map<String, dynamic>;

    return PokemonMoveDto(
      moveId: move['id'] as int,
      moveName: move['name'] as String,
      learnMethodId: method['id'] as int,
      versionGroupId: group['id'] as int,
      versionGroupName: group['name'] as String,
      level: json['level'] as int? ?? 0,
    );
  }
}
