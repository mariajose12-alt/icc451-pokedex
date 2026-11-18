import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/features/pokemon/data/datasources/local/pokemon_local_datasource.dart';
import 'package:pokedex/features/pokemon/data/datasources/remote/pokemon_remote_datasource.dart';
import 'package:pokedex/features/pokemon/data/models/pokemon_dto.dart';
import 'package:pokedex/features/pokemon/data/repositories/offline_first_pokemon_repository.dart';
import 'package:pokedex/features/pokemon/data/sync/catalog_sync_coordinator.dart';

import '../../../helpers/fake_catalog_api.dart';

void main() {
  late AppDatabase db;
  late PokemonLocalDataSource local;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    local = PokemonLocalDataSource(dao: db.catalogoDao);
  });

  tearDown(() async {
    await db.close();
  });

  test('el detalle trae los 6 stats ordenados y el total', () async {
    final repository = OfflineFirstPokemonRepository(
      local: local,
      sync: CatalogSyncCoordinator(
        remote: PokemonRemoteDataSource(client: FakeCatalogApi(total: 3)),
        local: local,
        retryDelays: const [],
      ),
    );
    await repository.refreshCatalog();

    final pokemon = await repository.watchPokemon(1).first;

    expect(pokemon, isNotNull);
    expect(pokemon!.stats.map((s) => s.statId).toList(), [1, 2, 3, 4, 5, 6]);
    // El fake usa 10 * statId + id: para el Pokémon 1 son 11, 21, ... 61.
    expect(pokemon.stats.first.baseStat, 11);
    expect(pokemon.totalStats, 216);
  });

  test('un Pokémon de dos tipos no repite tipos ni stats', () async {
    // Se guarda directo: 2 tipos × 6 stats = 12 filas en el JOIN.
    await local.savePage([
      PokemonDto(
        id: 6,
        name: 'charizard',
        nationalDexNumber: 6,
        generationId: 1,
        height: 17,
        weight: 905,
        types: const [
          PokemonTypeDto(slot: 1, typeId: 10, typeName: 'fire'),
          PokemonTypeDto(slot: 2, typeId: 3, typeName: 'flying'),
        ],
        artworkUrl: 'a6.png',
        spriteUrl: 's6.png',
        stats: const [
          PokemonStatDto(statId: 1, baseStat: 78),
          PokemonStatDto(statId: 2, baseStat: 84),
          PokemonStatDto(statId: 3, baseStat: 78),
          PokemonStatDto(statId: 4, baseStat: 109),
          PokemonStatDto(statId: 5, baseStat: 85),
          PokemonStatDto(statId: 6, baseStat: 100),
        ],
      ),
    ], isLast: true);

    final pokemon = await local.watchPokemon(6).first;

    expect(pokemon!.types.map((t) => t.name).toList(), ['fire', 'flying']);
    expect(pokemon.stats, hasLength(6));
    expect(pokemon.totalStats, 534);
  });

  test('un Pokémon sin stats guardados se lee con lista vacía y total 0',
          () async {
        await local.savePage([
          const PokemonDto(
            id: 7,
            name: 'squirtle',
            nationalDexNumber: 7,
            generationId: 1,
            height: 5,
            weight: 90,
            types: [PokemonTypeDto(slot: 1, typeId: 11, typeName: 'water')],
            artworkUrl: 'a7.png',
            spriteUrl: 's7.png',
          ),
        ], isLast: true);

        final pokemon = await local.watchPokemon(7).first;

        expect(pokemon, isNotNull);
        expect(pokemon!.stats, isEmpty);
        expect(pokemon.totalStats, 0);
      });
}