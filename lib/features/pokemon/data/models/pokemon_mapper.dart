import 'package:pokedex/features/pokemon/data/models/pokemon_dto.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_type.dart';

/// Convierte DTOs (formato de PokeAPI) en entidades del dominio.
extension PokemonDtoMapper on PokemonDto {
  Pokemon toDomain() {
    // Los tipos se ordenan por slot: el principal primero.
    final sortedTypes = [...types]..sort((a, b) => a.slot.compareTo(b.slot));

    final domainTypes = <PokemonType>[];
    for (final type in sortedTypes) {
      domainTypes.add(PokemonType(id: type.typeId, name: type.typeName));
    }

    return Pokemon(
      id: id,
      name: name,
      nationalDexNumber: nationalDexNumber,
      generationId: generationId,
      height: height,
      weight: weight,
      types: domainTypes,
      artworkUrl: artworkUrl,
      spriteUrl: spriteUrl,
    );
  }
}
