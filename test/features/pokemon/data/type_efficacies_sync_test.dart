import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/core/sync/sync_status.dart';
import 'package:pokedex/features/pokemon/data/datasources/local/pokemon_local_datasource.dart';
import 'package:pokedex/features/pokemon/data/datasources/remote/pokemon_remote_datasource.dart';
import 'package:pokedex/features/pokemon/data/repositories/offline_first_pokemon_repository.dart';
import 'package:pokedex/features/pokemon/data/sync/catalog_sync_coordinator.dart';

import '../../../helpers/fake_catalog_api.dart';

void main() {
  late AppDatabase db;
  late FakeCatalogApi api;
  late OfflineFirstPokemonRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    api = FakeCatalogApi(total: 3);
    final local = PokemonLocalDataSource(dao: db.catalogoDao);
    repository = OfflineFirstPokemonRepository(
      local: local,
      sync: CatalogSyncCoordinator(
        remote: PokemonRemoteDataSource(client: api),
        local: local,
        retryDelays: const [],
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('al terminar el catálogo se guardan las efectividades', () async {
    await repository.refreshCatalog();

    final rows = await db.select(db.typeEfficacies).get();
    expect(rows.length, 3);

    // La inmunidad (0 %) se guarda tal cual, no se descarta.
    final inmune = rows.firstWhere((r) => r.damageTypeId == 1);
    expect(inmune.damageFactor, 0);
  });

  test('si ya están guardadas, no se vuelven a pedir', () async {
    await repository.refreshCatalog();
    await repository.refreshCatalog(onlyIfStale: true);

    expect(api.efficacyCalls, 1);
  });

  test('si fallan, el catálogo igual queda completo y en ok', () async {
    api.failEfficacies = true;

    await repository.refreshCatalog();

    final state = await db.catalogoDao.readSyncState(SyncResources.catalog);
    expect(state!.status, SyncStatus.ok);
    expect(await db.select(db.pokemons).get(), hasLength(3));
    expect(await db.select(db.typeEfficacies).get(), isEmpty);
  });

  test('con el catálogo vigente, reintenta las que faltaban', () async {
    api.failEfficacies = true;
    await repository.refreshCatalog();

    api.failEfficacies = false;
    await repository.refreshCatalog(onlyIfStale: true);

    expect(await db.select(db.typeEfficacies).get(), hasLength(3));
    // Solo se pidieron las páginas del catálogo una vez (1 página).
    expect(api.calls.length, 1);
  });
}
