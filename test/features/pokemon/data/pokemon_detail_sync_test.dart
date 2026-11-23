import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/core/network/network_exceptions.dart';
import 'package:pokedex/core/sync/sync_status.dart';
import 'package:pokedex/features/pokemon/data/datasources/local/pokemon_detail_local_datasource.dart';
import 'package:pokedex/features/pokemon/data/datasources/remote/pokemon_remote_datasource.dart';
import 'package:pokedex/features/pokemon/data/sync/pokemon_detail_sync_coordinator.dart';

import '../../../helpers/fake_detail_api.dart';

void main() {
  late AppDatabase db;
  late FakeDetailApi api;
  late PokemonDetailSyncCoordinator coordinator;

  PokemonDetailSyncCoordinator build({Duration minInterval = Duration.zero}) {
    return PokemonDetailSyncCoordinator(
      remote: PokemonRemoteDataSource(client: api),
      local: PokemonDetailLocalDataSource(dao: db.detalleDao),
      minInterval: minInterval,
      retryDelays: const [],
    );
  }

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    api = FakeDetailApi();
    // Sin espera mínima: casi todas las pruebas repiten la consulta.
    coordinator = build();
  });

  tearDown(() async {
    await db.close();
  });

  Future<Map<String, int>> counts() async {
    return {
      'pokemons': (await db.select(db.pokemons).get()).length,
      'types': (await db.select(db.pokemonTypes).get()).length,
      'stats': (await db.select(db.pokemonStats).get()).length,
      'abilities': (await db.select(db.abilities).get()).length,
      'pokemonAbilities': (await db.select(db.pokemonAbilities).get()).length,
      'eggGroups': (await db.select(db.pokemonEggGroups).get()).length,
      'evolutionNodes': (await db.select(db.evolutionNodes).get()).length,
      'forms': (await db.select(db.pokemonForms).get()).length,
      'formTypes': (await db.select(db.pokemonFormTypes).get()).length,
      'moves': (await db.select(db.moves).get()).length,
      'versionGroups': (await db.select(db.versionGroups).get()).length,
      'pokemonMoves': (await db.select(db.pokemonMoves).get()).length,
    };
  }

  test(
    'abrir un Pokémon que no estaba guardado lo guarda todo (PA-02)',
    () async {
      expect(await db.select(db.pokemons).get(), isEmpty);

      await coordinator.refresh(1);

      expect(await counts(), {
        'pokemons': 1,
        'types': 2,
        'stats': 6,
        'abilities': 2,
        'pokemonAbilities': 2,
        'eggGroups': 2,
        'evolutionNodes': 2,
        'forms': 1,
        'formTypes': 1,
        'moves': 2,
        'versionGroups': 1,
        'pokemonMoves': 2,
      });
    },
  );

  test('guarda el nombre de la habilidad y su efecto resumido', () async {
    await coordinator.refresh(1);

    final overgrow = await (db.select(
      db.abilities,
    )..where((a) => a.id.equals(65))).getSingle();
    expect(overgrow.nameEs, 'Espesura');
    expect(overgrow.effectSummary, 'Boosts grass moves.');

    final hidden = await (db.select(
      db.pokemonAbilities,
    )..where((a) => a.abilityId.equals(34))).getSingle();
    expect(hidden.isHidden, isTrue);
  });

  test('repetir la consulta no duplica ningún registro (PA-13)', () async {
    await coordinator.refresh(1);
    final first = await counts();

    await coordinator.refresh(1);
    await coordinator.refresh(1);

    expect(await counts(), first);
  });

  test('si se consultó hace menos de 2 minutos, no vuelve a pedirlo', () async {
    final throttled = build(minInterval: const Duration(minutes: 2));

    await throttled.refresh(1);
    await throttled.refresh(1);

    expect(api.calls, [1]);
  });

  test('dos consultas a la vez comparten una sola llamada', () async {
    await Future.wait([coordinator.refresh(1), coordinator.refresh(1)]);

    expect(api.calls, [1]);
  });

  test(
    'restaura lo que se cambió en la base y no toca favoritos (PA-16)',
    () async {
      await coordinator.refresh(1);
      await db
          .into(db.favorites)
          .insert(FavoritesCompanion.insert(pokemonId: const Value(1)));

      // Como haría el inspector de la defensa: cambiar el nombre y quitar un tipo.
      await (db.update(db.pokemons)..where((p) => p.id.equals(1))).write(
        const PokemonsCompanion(name: Value('alterado')),
      );
      await (db.delete(db.pokemonTypes)..where((t) => t.slot.equals(2))).go();

      await coordinator.refresh(1);

      final pokemon = await (db.select(
        db.pokemons,
      )..where((p) => p.id.equals(1))).getSingle();
      expect(pokemon.name, 'bulbasaur');
      expect((await db.select(db.pokemonTypes).get()).length, 2);
      // Los favoritos siguen intactos (OF-21).
      expect((await db.select(db.favorites).get()).length, 1);
    },
  );

  test('si falla, conserva lo guardado y anota failed', () async {
    await coordinator.refresh(1);

    api.failWith = const NoConnectionException();
    await expectLater(
      coordinator.refresh(1),
      throwsA(isA<NoConnectionException>()),
    );

    // Los datos siguen ahí.
    expect((await counts())['abilities'], 2);

    final state = await db.detalleDao.readSyncState('detail:1');
    expect(state!.status, SyncStatus.failed);
    // La fecha del último éxito no se perdió.
    expect(state.lastSuccessfulAt, isNotNull);
  });

  test('tras un fallo, la siguiente apertura vuelve a intentar', () async {
    final throttled = build(minInterval: const Duration(minutes: 2));

    api.failWith = const NoConnectionException();
    await expectLater(
      throttled.refresh(1),
      throwsA(isA<NoConnectionException>()),
    );

    api.failWith = null;
    await throttled.refresh(1);

    // Un fallo no cuenta como "consultado hace poco".
    expect(api.calls.length, 2);
    expect((await counts())['pokemons'], 1);
  });
}
