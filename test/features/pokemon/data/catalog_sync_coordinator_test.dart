import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/core/network/network_exceptions.dart';
import 'package:pokedex/core/sync/sync_status.dart';
import 'package:pokedex/features/pokemon/data/datasources/local/pokemon_local_datasource.dart';
import 'package:pokedex/features/pokemon/data/datasources/remote/pokemon_remote_datasource.dart';
import 'package:pokedex/features/pokemon/data/sync/catalog_sync_coordinator.dart';

import '../../../helpers/fake_catalog_api.dart';

void main() {
  late AppDatabase db;
  late FakeCatalogApi api;
  late PokemonLocalDataSource local;
  late CatalogSyncCoordinator coordinator;

  void prepare(int total, {List<Duration> retryDelays = const []}) {
    api = FakeCatalogApi(total: total);
    local = PokemonLocalDataSource(dao: db.catalogoDao);
    coordinator = CatalogSyncCoordinator(
      remote: PokemonRemoteDataSource(client: api),
      local: local,
      retryDelays: retryDelays,
    );
  }

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('descarga todo en páginas de 250 y queda en ok', () async {
    prepare(600); // 250 + 250 + 100

    await coordinator.sync();

    expect(api.calls, [0, 250, 500]);
    expect(await db.catalogoDao.watchCount().first, 600);
    final estado = await db.catalogoDao.readSyncState(SyncResources.catalog);
    expect(estado!.status, SyncStatus.ok);
    expect(estado.lastSuccessfulAt, isNotNull);
  });

  test('si el total es múltiplo de la página, cierra con una vacía', () async {
    prepare(500);

    await coordinator.sync();

    expect(api.calls, [0, 250, 500]);
    expect(await db.catalogoDao.watchCount().first, 500);
    final estado = await db.catalogoDao.readSyncState(SyncResources.catalog);
    expect(estado!.status, SyncStatus.ok);
  });

  test('si falla a mitad conserva lo descargado y marca failed', () async {
    prepare(600);
    api.failOnCall = 2;

    await expectLater(
      coordinator.sync(),
      throwsA(isA<NoConnectionException>()),
    );

    expect(await db.catalogoDao.watchCount().first, 250);
    final estado = await db.catalogoDao.readSyncState(SyncResources.catalog);
    expect(estado!.status, SyncStatus.failed);
    expect(estado.cursorOrOffset, '250');
  });

  test('después de un fallo reanuda desde el cursor, no desde cero', () async {
    prepare(600);
    api.failOnCall = 2;
    await expectLater(coordinator.sync(), throwsA(isA<PokeApiException>()));
    api.calls.clear();
    api.failOnCall = null; // ahora la API vuelve a funcionar

    await coordinator.sync();

    expect(api.calls, [250, 500]); // no vuelve a pedir la primera página
    expect(await db.catalogoDao.watchCount().first, 600);
    final estado = await db.catalogoDao.readSyncState(SyncResources.catalog);
    expect(estado!.status, SyncStatus.ok);
  });

  test('dos sync() a la vez hacen una sola ronda de llamadas', () async {
    prepare(600);

    await Future.wait([coordinator.sync(), coordinator.sync()]);

    expect(api.calls, [0, 250, 500]); // no 6 llamadas
  });

  test('avisa cuando empieza y cuando termina', () async {
    prepare(100);
    final eventos = <bool>[];
    final suscripcion = coordinator.runningChanges.listen(eventos.add);

    await coordinator.sync();
    await Future<void>.delayed(Duration.zero);
    await suscripcion.cancel();

    expect(eventos, [true, false]);
    expect(coordinator.isRunning, isFalse);
  });

  test('el catálogo guardado se lee con sus tipos como entidades', () async {
    prepare(3);
    await coordinator.sync();

    final catalogo = await local.watchCatalog().first;

    expect(catalogo.map((p) => p.name), [
      'pokemon-1',
      'pokemon-2',
      'pokemon-3',
    ]);
    expect(catalogo.first.types.single.name, 'grass');
    expect(catalogo.first.artworkUrl, 'a1.png');
  });

  test('si una página falla una vez, la reintenta y termina bien', () async {
    // Esperas de 0 para que el test no tarde.
    prepare(600, retryDelays: const [Duration.zero]);
    api.failOnCall = 2; // falla solo la segunda llamada

    await coordinator.sync();

    // Llamada 2 falló, la 3 repite la misma página (cursor 250).
    expect(api.calls, [0, 250, 250, 500]);
    expect(await db.catalogoDao.watchCount().first, 600);
    final estado = await db.catalogoDao.readSyncState(SyncResources.catalog);
    expect(estado!.status, SyncStatus.ok);
  });

  test(
    'si agota los reintentos, marca failed y conserva lo descargado',
    () async {
      prepare(600, retryDelays: const [Duration.zero, Duration.zero]);
      api.failFromCall = 2; // desde la segunda llamada todo falla

      await expectLater(
        coordinator.sync(),
        throwsA(isA<NoConnectionException>()),
      );

      // 1 página buena + 1 intento + 2 reintentos de la segunda página.
      expect(api.calls, [0, 250, 250, 250]);
      expect(await db.catalogoDao.watchCount().first, 250);
      final estado = await db.catalogoDao.readSyncState(SyncResources.catalog);
      expect(estado!.status, SyncStatus.failed);
      expect(estado.cursorOrOffset, '250');
    },
  );

  test('el límite de solicitudes no se reintenta', () async {
    prepare(600, retryDelays: const [Duration.zero, Duration.zero]);
    api.failFromCall = 1;
    api.failWith = const RateLimitException();

    await expectLater(coordinator.sync(), throwsA(isA<RateLimitException>()));

    expect(api.calls.length, 1); // una sola llamada: no insistió
  });
}
