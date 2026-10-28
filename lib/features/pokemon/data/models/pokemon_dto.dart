/// Copia fiel de lo que devuelve PokeAPI para un Pokémon.
/// Solo la capa data conoce estas clases (ARQ-04).
class PokemonTypeDto {
  const PokemonTypeDto({
    required this.slot,
    required this.typeId,
    required this.typeName,
  });

  /// 1 = tipo principal, 2 = secundario.
  final int slot;
  final int typeId;
  final String typeName;

  factory PokemonTypeDto.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as Map<String, dynamic>;
    return PokemonTypeDto(
      slot: json['slot'] as int,
      typeId: type['id'] as int,
      typeName: type['name'] as String,
    );
  }
}

class PokemonDto {
  const PokemonDto({
    required this.id,
    required this.name,
    required this.nationalDexNumber,
    required this.generationId,
    required this.height,
    required this.weight,
    required this.types,
    required this.artworkUrl,
    required this.spriteUrl,
  });

  final int id;
  final String name;
  final int nationalDexNumber;
  final int generationId;

  /// En decímetros, tal como los da la API.
  final int height;

  /// En hectogramos, tal como los da la API.
  final int weight;

  final List<PokemonTypeDto> types;
  final String? artworkUrl;
  final String? spriteUrl;

  factory PokemonDto.fromJson(Map<String, dynamic> json) {
    // Tipos: lista de { slot, type { id, name } }.
    final typesJson = json['pokemontypes'] as List<dynamic>;
    final types = <PokemonTypeDto>[];
    for (final item in typesJson) {
      types.add(PokemonTypeDto.fromJson(item as Map<String, dynamic>));
    }

    // Imágenes: PokeAPI devuelve una lista con un solo elemento.
    // Si la lista viene vacía, no hay imágenes y la UI usa un respaldo.
    final spritesList = json['pokemonsprites'] as List<dynamic>;
    final sprites = spritesList.isEmpty
        ? null
        : spritesList.first as Map<String, dynamic>;
    final artwork = sprites?['artwork'];
    final sprite = sprites?['sprite'];

    // Especie: es un objeto con el número nacional y la generación.
    final species = json['pokemonspecy'] as Map<String, dynamic>;

    return PokemonDto(
      id: json['id'] as int,
      name: json['name'] as String,
      nationalDexNumber: species['id'] as int,
      generationId: species['generation_id'] as int,
      height: json['height'] as int,
      weight: json['weight'] as int,
      types: types,
      artworkUrl: artwork is String ? artwork : null,
      spriteUrl: sprite is String ? sprite : null,
    );
  }
}

/// Una página de resultados más el total remoto.
class CatalogPageDto {
  const CatalogPageDto({required this.items, required this.totalCount});

  final List<PokemonDto> items;

  /// Total de Pokémon por defecto en PokeAPI (1025 al día de hoy).
  final int totalCount;

  factory CatalogPageDto.fromJson(Map<String, dynamic> data) {
    final itemsJson = data['pokemon'] as List<dynamic>;
    final items = <PokemonDto>[];
    for (final item in itemsJson) {
      items.add(PokemonDto.fromJson(item as Map<String, dynamic>));
    }

    final aggregate = data['pokemon_aggregate'] as Map<String, dynamic>;
    final inner = aggregate['aggregate'] as Map<String, dynamic>;

    return CatalogPageDto(items: items, totalCount: inner['count'] as int);
  }
}
