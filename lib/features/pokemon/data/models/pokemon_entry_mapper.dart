import 'package:pokedex/core/database/daos/catalogo_dao.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_type.dart';

/// Convierte lo que devuelve Drift en la entidad del dominio.
/// Es el camino inverso de `pageToCompanions`.
extension PokemonWithTypesMapper on PokemonWithTypes {
  Pokemon toDomain() {
    final domainTypes = <PokemonType>[];
    for (final type in types) {
      domainTypes.add(PokemonType(id: type.id, name: type.name));
    }

    return Pokemon(
      id: pokemon.id,
      name: pokemon.name,
      nationalDexNumber: pokemon.nationalDexNumber,
      generationId: pokemon.generationId,
      // En la base son opcionales; la entidad pide un valor.
      height: pokemon.height ?? 0,
      weight: pokemon.weight ?? 0,
      types: domainTypes,
      artworkUrl: pokemon.artworkUrl,
      spriteUrl: pokemon.spriteUrl,
    );
  }
}
