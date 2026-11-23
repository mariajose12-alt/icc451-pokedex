import 'package:pokedex/core/database/daos/catalogo_dao.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_type.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_stat.dart';

/// Convierte lo que devuelve Drift en la entidad del dominio.
/// Es el camino inverso de `pageToCompanions`.
extension PokemonWithTypesMapper on PokemonWithTypes {
  Pokemon toDomain() {
    final domainTypes = <PokemonType>[];
    for (final type in types) {
      domainTypes.add(PokemonType(id: type.id, name: type.name));
    }

    final domainStats = <PokemonStat>[];
    for (final stat in stats) {
      domainStats.add(
        PokemonStat(statId: stat.statId, baseStat: stat.baseStat),
      );
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
      stats: domainStats,
      artworkUrl: pokemon.artworkUrl,
      spriteUrl: pokemon.spriteUrl,
    );
  }
}
