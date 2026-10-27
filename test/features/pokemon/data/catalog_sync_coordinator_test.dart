import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/core/network/network_exceptions.dart';
import 'package:pokedex/core/network/poke_api_client.dart';
import 'package:pokedex/core/sync/sync_status.dart';
import 'package:pokedex/features/pokemon/data/datasources/local/pokemon_local_datasource.dart';
import 'package:pokedex/features/pokemon/data/datasources/remote/pokemon_remote_datasource.dart';
import 'package:pokedex/features/pokemon/data/sync/catalog_sync_coordinator.dart';

// API falsa con [total] Pokémon (ids 1..total). Responde según el cursor
// que reciba, igual que la API real, y recuerda cada llamada.
class FakeCatalogApi implements PokeApiClient {
  FakeCatalogApi({required this.total});

  final int total;

  /// Valores de lastId con los que se llamó, en orden.
  final List<int> calls = <int>[];

  /// Número de llamada (1, 2, 3...) en la que debe fallar. null = nunca.
  int? failOnCall;

  @override
  final String url = 'fake';

  @override
  final Duration timeout = const Duration(seconds: 1);

  @override
  Future<Map<String, dynamic>> query(
    String document, {
    Map<String, dynamic> variables = const <String, dynamic>{},
  }) async {
    final lastId = variables['lastId'] as int;
    final pageSize = variables['pageSize'] as int;
    calls.add(lastId);

    if (failOnCall == calls.length) {
      throw const NoConnectionException();
    }

    final items = <Map<String, dynamic>>[];
    for (var id = lastId + 1; id <= total && items.length < pageSize; id++) {
      items.add(<String, dynamic>{
        'id': id,
        'name': 'pokemon-$id',
        'height': 1,
        'weight': 1,
        'pokemonsprites': <dynamic>[
          <String, dynamic>{'artwork': 'a$id.png', 'sprite': 's$id.png'},
        ],
        'pokemontypes': <dynamic>[
          <String, dynamic>{
            'slot': 1,
            'type': <String, dynamic>{'id': 12, 'name': 'grass'},
          },
        ],
        'pokemonspecy': <String, dynamic>{'id': id, 'generation_id': 1},
      });
    }

    return <String, dynamic>{
      'pokemon': items,
      'pokemon_aggregate': <String, dynamic>{
        'aggregate': <String, dynamic>{'count': total},
      },
    };
  }
}

void main() {
  late AppDatabase db;
  late FakeCatalogApi api;
  late PokemonLocalDataSource local;
  late CatalogSyncCoordinator coordinator;

  void prepare(int total) {
    api = FakeCatalogApi(total: total);
    local = PokemonLocalDataSource(dao: db.catalogoDao);
    coordinator = CatalogSyncCoordinator(
      remote: PokemonRemoteDataSource(client: api),
      local: local,
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
}
