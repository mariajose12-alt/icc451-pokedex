import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/features/pokemon/data/datasources/local/pokemon_local_datasource.dart';
import 'package:pokedex/features/pokemon/data/datasources/remote/pokemon_remote_datasource.dart';
import 'package:pokedex/features/pokemon/data/repositories/offline_first_pokemon_repository.dart';
import 'package:pokedex/features/pokemon/data/sync/catalog_sync_coordinator.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';

import '../../../helpers/fake_catalog_api.dart';

void main() {
  late AppDatabase db;
  late OfflineFirstPokemonRepository repository;

  setUp(() async {
    // Base real pero en memoria: se borra al terminar cada prueba.
    db = AppDatabase(NativeDatabase.memory());

    final local = PokemonLocalDataSource(dao: db.catalogoDao);
    final coordinator = CatalogSyncCoordinator(
      remote: PokemonRemoteDataSource(client: FakeCatalogApi(total: 3)),
      local: local,
      retryDelays: const [],
    );
    repository = OfflineFirstPokemonRepository(local: local, sync: coordinator);

    // Se llena la base con los Pokémon 1, 2 y 3.
    await repository.refreshCatalog();
  });

  tearDown(() async {
    await db.close();
  });

  test('devuelve solo el Pokémon pedido, con sus tipos', () async {
    final pokemon = await repository.watchPokemon(2).first;

    expect(pokemon, isNotNull);
    expect(pokemon!.id, 2);
    expect(pokemon.name, 'pokemon-2');
    // La API falsa le da un solo tipo: grass.
    expect(pokemon.types.map((type) => type.name), ['grass']);
  });

  test('un id que no existe emite null', () async {
    final pokemon = await repository.watchPokemon(99).first;

    expect(pokemon, isNull);
  });

  test('si la fila cambia en la base, el stream emite el dato nuevo', () async {
    final emitted = <Pokemon?>[];
    final subscription = repository.watchPokemon(1).listen(emitted.add);
    addTearDown(subscription.cancel);

    // Deja que llegue la primera emisión (el dato original).
    await pumpEventQueue();
    expect(emitted.last?.name, 'pokemon-1');

    // Se modifica el nombre directamente en la base, como haría el
    // inspector de la defensa (PA-16).
    await (db.update(db.pokemons)..where((p) => p.id.equals(1))).write(
      const PokemonsCompanion(name: Value('renombrado')),
    );
    await pumpEventQueue();

    expect(emitted.last?.name, 'renombrado');
  });
}
