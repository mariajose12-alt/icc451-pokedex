import 'package:drift/drift.dart' show Value;
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/features/pokemon/data/models/pokemon_dto.dart';

/// Las tres listas que necesita `CatalogoDao.savePage` para una página.
class PageCompanions {
  const PageCompanions({
    required this.types,
    required this.pokemons,
    required this.pokemonTypes,
    required this.stats,
  });

  final List<PokeTypesCompanion> types;
  final List<PokemonsCompanion> pokemons;
  final List<PokemonTypesCompanion> pokemonTypes;
  final List<PokemonStatsCompanion> stats;
}

/// Convierte los DTOs de una página (formato de PokeAPI) en filas para Drift.
/// [now] se recibe como parámetro para poder probarlo con una fecha fija.
PageCompanions pageToCompanions(List<PokemonDto> items, DateTime now) {
  // Un mismo tipo (p. ej. "grass") aparece en muchos Pokémon de la página:
  // se guarda una sola vez, por eso el mapa por id.
  final typesById = <int, PokeTypesCompanion>{};
  final pokemons = <PokemonsCompanion>[];
  final relations = <PokemonTypesCompanion>[];
  final stats = <PokemonStatsCompanion>[];

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

    stats.add(statsToCompanion(dto));
  }

  return PageCompanions(
    types: typesById.values.toList(),
    pokemons: pokemons,
    pokemonTypes: relations,
    stats: stats,
  );
}

/// Convierte las estadisticas de un Pokemon en una fila de PokemonStats.
/// Si falta alguna de las sesi falla: no se guarda una fila incompleta
PokemonStatsCompanion statsToCompanion(PokemonDto dto) {
  // Mapa de nombre de PokeAPI a valor: {'hp' : 45, 'attack' : 49, ...}
  final values = <String, int>{};
  for (final stat in dto.stats) {
    values[stat.statName] = stat.baseStat;
  }

  // Funcion local: busca un valor y falla si no existe
  int valueOf(String name) {
    final value = values[name];
    if (value == null) {
      throw FormatException(
        'Falta la estadística "$name" del Pokémon ${dto.id}',
      );
    }
    return value;
  }

  return PokemonStatsCompanion.insert(
    pokemonId: Value(dto.id),
    hp: valueOf('hp'),
    attack: valueOf('attack'),
    defense: valueOf('defense'),
    specialAttack: valueOf('special-attack'),
    specialDefense: valueOf('special-defense'),
    speed: valueOf('speed'),
  );
}
