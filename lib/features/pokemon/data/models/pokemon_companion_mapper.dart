import 'package:drift/drift.dart' show Value;
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/features/pokemon/data/models/pokemon_dto.dart';

/// Las tres listas que necesita `CatalogoDao.savePage` para una página.
class PageCompanions {
  const PageCompanions({
    required this.types,
    required this.pokemons,
    required this.pokemonTypes,
  });

  final List<PokeTypesCompanion> types;
  final List<PokemonsCompanion> pokemons;
  final List<PokemonTypesCompanion> pokemonTypes;
}

/// Convierte los DTOs de una página (formato de PokeAPI) en filas para Drift.
/// [now] se recibe como parámetro para poder probarlo con una fecha fija.
PageCompanions pageToCompanions(List<PokemonDto> items, DateTime now) {
  // Un mismo tipo (p. ej. "grass") aparece en muchos Pokémon de la página:
  // se guarda una sola vez, por eso el mapa por id.
  final typesById = <int, PokeTypesCompanion>{};
  final pokemons = <PokemonsCompanion>[];
  final relations = <PokemonTypesCompanion>[];

  for (final dto in items) {
    pokemons.add(
      PokemonsCompanion.insert(
        id: Value(dto.id),
        name: dto.name,
        nationalDexNumber: dto.nationalDexNumber,
        generationId: dto.generationId,
        height: Value(dto.height),
        weight: Value(dto.weight),
        artworkUrl: Value(dto.artworkUrl),
        spriteUrl: Value(dto.spriteUrl),
        updatedAt: now,
        // artworkLocalPath no se incluye a propósito: así el upsert no
        // borra la ruta de una imagen ya descargada (T-009).
      ),
    );

    for (final type in dto.types) {
      typesById[type.typeId] = PokeTypesCompanion.insert(
        id: Value(type.typeId),
        name: type.typeName,
      );
      relations.add(
        PokemonTypesCompanion.insert(
          pokemonId: dto.id,
          typeId: type.typeId,
          slot: type.slot,
        ),
      );
    }
  }

  return PageCompanions(
    types: typesById.values.toList(),
    pokemons: pokemons,
    pokemonTypes: relations,
  );
}
