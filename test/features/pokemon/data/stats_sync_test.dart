import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/features/pokemon/data/datasources/local/pokemon_local_datasource.dart';
import 'package:pokedex/features/pokemon/data/datasources/remote/pokemon_remote_datasource.dart';
import 'package:pokedex/features/pokemon/data/repositories/offline_first_pokemon_repository.dart';
import 'package:pokedex/features/pokemon/data/sync/catalog_sync_coordinator.dart';

import '../../../helpers/fake_catalog_api.dart';

void main() {
  late AppDatabase db;
  late OfflineFirstPokemonRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    final local = PokemonLocalDataSource(dao: db.catalogoDao);
    repository = OfflineFirstPokemonRepository(
      local: local,
      sync: CatalogSyncCoordinator(
        remote: PokemonRemoteDataSource(client: FakeCatalogApi(total: 3)),
        local: local,
        retryDelays: const [],
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('la sincronización guarda los 6 stats de cada Pokémon', () async {
    await repository.refreshCatalog();

    final rows = await db.select(db.pokemonStats).get();

    // 3 Pokémon × 6 stats.
    expect(rows.length, 18);

    final deUno = rows.where((row) => row.pokemonId == 1).toList();
    expect(deUno.map((row) => row.statId).toSet(), {1, 2, 3, 4, 5, 6});
    // 10 * statId + id del Pokémon: hp (1) del Pokémon 1 = 11.
    expect(deUno.firstWhere((row) => row.statId == 1).baseStat, 11);
  });

  test('sincronizar otra vez no duplica los stats', () async {
    await repository.refreshCatalog();
    await repository.refreshCatalog();

    final rows = await db.select(db.pokemonStats).get();

    expect(rows.length, 18);
  });
}
