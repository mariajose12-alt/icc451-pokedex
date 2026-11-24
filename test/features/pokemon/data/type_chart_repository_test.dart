import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/features/pokemon/data/datasources/local/pokemon_local_datasource.dart';
import 'package:pokedex/features/pokemon/data/datasources/remote/pokemon_remote_datasource.dart';
import 'package:pokedex/features/pokemon/data/repositories/offline_first_pokemon_repository.dart';
import 'package:pokedex/features/pokemon/data/repositories/offline_first_type_chart_repository.dart';
import 'package:pokedex/features/pokemon/data/sync/catalog_sync_coordinator.dart';
import 'package:pokedex/features/pokemon/domain/entities/type_chart.dart';

import '../../../helpers/fake_catalog_api.dart';

void main() {
  late AppDatabase db;
  late OfflineFirstPokemonRepository pokemonRepository;
  late OfflineFirstTypeChartRepository chartRepository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    final local = PokemonLocalDataSource(dao: db.catalogoDao);
    pokemonRepository = OfflineFirstPokemonRepository(
      local: local,
      sync: CatalogSyncCoordinator(
        remote: PokemonRemoteDataSource(client: FakeCatalogApi(total: 3)),
        local: local,
        retryDelays: const [],
      ),
    );
    chartRepository = OfflineFirstTypeChartRepository(local: local);
  });

  tearDown(() async {
    await db.close();
  });

  test('antes de descargar, la tabla está vacía', () async {
    final chart = await chartRepository.watchTypeChart().first;

    expect(chart.isEmpty, isTrue);
  });

  test(
    'después de sincronizar, la tabla trae los factores guardados',
    () async {
      await pokemonRepository.refreshCatalog();

      final chart = await chartRepository.watchTypeChart().first;

      // Las 3 filas del FakeCatalogApi.
      expect(chart.factor(12, 10), 50);
      expect(chart.factor(10, 12), 200);
      expect(chart.factor(1, 8), 0);
      // Un par que no está guardado es daño normal.
      expect(chart.factor(2, 2), TypeChart.neutralPercent);
    },
  );

  test('si la tabla llega con el detalle abierto, el stream avisa', () async {
    final emisiones = <bool>[];
    final sub = chartRepository.watchTypeChart().listen(
      (chart) => emisiones.add(chart.isEmpty),
    );

    // Deja que llegue la primera emisión (vacía) antes de sincronizar.
    await Future<void>.delayed(Duration.zero);
    await pokemonRepository.refreshCatalog();
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    // Primero vacía (true), luego con datos (false).
    expect(emisiones.first, isTrue);
    expect(emisiones.last, isFalse);
  });
}
