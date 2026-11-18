import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/features/pokemon/data/datasources/local/pokemon_detail_local_datasource.dart';
import 'package:pokedex/features/pokemon/data/datasources/remote/pokemon_remote_datasource.dart';
import 'package:pokedex/features/pokemon/data/repositories/offline_first_pokemon_detail_repository.dart';
import 'package:pokedex/features/pokemon/data/sync/pokemon_detail_sync_coordinator.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_extras.dart';

import '../../../helpers/fake_detail_api.dart';

void main() {
  late AppDatabase db;
  late OfflineFirstPokemonDetailRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    final local = PokemonDetailLocalDataSource(dao: db.detalleDao);
    repository = OfflineFirstPokemonDetailRepository(
      sync: PokemonDetailSyncCoordinator(
        remote: PokemonRemoteDataSource(client: FakeDetailApi()),
        local: local,
        retryDelays: const [],
      ),
      local: local,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('antes de descargar, todo vacío y sin marcar como descargado', () async {
    final extras = await repository.watchExtras(1).first;

    expect(extras, PokemonExtras.empty);
  });

  test(
    'después de descargar, trae habilidades, egg groups, cadena y formas',
    () async {
      await repository.refreshDetail(1);
      final extras = await repository.watchExtras(1).first;

      expect(extras.downloaded, isTrue);

      // Las normales primero, la oculta al final.
      expect(extras.abilities.map((a) => a.name), ['overgrow', 'chlorophyll']);
      expect(extras.abilities.first.displayName('es'), 'Espesura');
      expect(extras.abilities.last.isHidden, isTrue);
      // Sin traducción al español: usa el inglés.
      expect(extras.abilities.last.displayName('es'), 'Chlorophyll');

      expect(extras.eggGroups, ['monster', 'plant']);

      expect(extras.evolution.map((s) => s.name), ['bulbasaur', 'ivysaur']);
      expect(extras.evolution.last.trigger, 'level-up');

      expect(extras.forms.single.typeIds, [12]);
      expect(extras.forms.single.hasShiny, isTrue);
    },
  );

  test('el stream emite de nuevo cuando llegan los datos', () async {
    final emitted = <PokemonExtras>[];
    final downloaded = Completer<void>();

    final subscription = repository.watchExtras(1).listen((extras) {
      emitted.add(extras);
      if (extras.downloaded && !downloaded.isCompleted) {
        downloaded.complete();
      }
    });

    try {
      await repository
          .refreshDetail(1)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw StateError('1) refreshDetail no terminó'),
          );
      await downloaded.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw StateError(
          '2) refreshDetail terminó pero el stream no emitió downloaded=true. '
          'Emisiones recibidas: ${emitted.length}',
        ),
      );
    } finally {
      await subscription.cancel();
    }

    expect(emitted.first.downloaded, isFalse);
    expect(emitted.last.downloaded, isTrue);
    expect(emitted.last.abilities.length, 2);
  });
}
