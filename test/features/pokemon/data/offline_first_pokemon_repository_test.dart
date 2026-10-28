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
  late FakeCatalogApi api;
  late PokemonLocalDataSource local;
  late CatalogSyncCoordinator coordinator;

  // [maxAge] permite simular datos viejos (Duration.zero) en las pruebas.
  OfflineFirstPokemonRepository buildRepository({
    required int total,
    Duration maxAge = OfflineFirstPokemonRepository.defaultCatalogMaxAge,
  }) {
    api = FakeCatalogApi(total: total);
    local = PokemonLocalDataSource(dao: db.catalogoDao);
    coordinator = CatalogSyncCoordinator(
      remote: PokemonRemoteDataSource(client: api),
      local: local,
    );
    return OfflineFirstPokemonRepository(
      local: local,
      sync: coordinator,
      catalogMaxAge: maxAge,
    );
  }

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('automática sin datos: sincroniza', () async {
    final repository = buildRepository(total: 3);

    await repository.refreshCatalog(onlyIfStale: true);

    expect(api.calls, [0]);
    expect(await db.catalogoDao.watchCount().first, 3);
  });

  test('automática con datos vigentes: no llama a la API (PS-03)', () async {
    final repository = buildRepository(total: 3);
    await repository.refreshCatalog();
    api.calls.clear();

    await repository.refreshCatalog(onlyIfStale: true);

    expect(api.calls, isEmpty);
  });

  test('manual con datos vigentes: sincroniza igual', () async {
    final repository = buildRepository(total: 3);
    await repository.refreshCatalog();
    api.calls.clear();

    await repository.refreshCatalog();

    expect(api.calls, [0]);
  });

  test('automática con datos viejos: sincroniza', () async {
    // Con vigencia cero, cualquier dato se considera viejo.
    final repository = buildRepository(total: 3, maxAge: Duration.zero);
    await repository.refreshCatalog();
    api.calls.clear();

    await repository.refreshCatalog(onlyIfStale: true);

    expect(api.calls, [0]);
  });

  test('automática después de un fallo: reanuda desde el cursor', () async {
    final repository = buildRepository(total: 600);
    api.failOnCall = 2;
    await expectLater(repository.refreshCatalog(), throwsA(anything));
    api.calls.clear();
    api.failOnCall = null;

    // Aunque el fallo fue hace un instante, el estado es "failed":
    // los datos no cuentan como vigentes y se continúa.
    await repository.refreshCatalog(onlyIfStale: true);

    expect(api.calls, [250, 500]);
    expect(await db.catalogoDao.watchCount().first, 600);
  });
}
