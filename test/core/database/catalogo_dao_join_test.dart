import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/core/sync/sync_status.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  PokemonsCompanion pokemon(int id, String name) {
    return PokemonsCompanion.insert(
      id: Value(id),
      name: name,
      nationalDexNumber: id,
      generationId: 1,
      updatedAt: DateTime(2026, 10, 27),
    );
  }

  // Estadísticas de Bulbasaur (total 318) y de Ditto (todas 48, total 288).
  PokemonStatsCompanion statsBulbasaur() => PokemonStatsCompanion.insert(
    pokemonId: const Value(1),
    hp: 45,
    attack: 49,
    defense: 49,
    specialAttack: 65,
    specialDefense: 65,
    speed: 45,
  );

  PokemonStatsCompanion statsDitto() => PokemonStatsCompanion.insert(
    pokemonId: const Value(132),
    hp: 48,
    attack: 48,
    defense: 48,
    specialAttack: 48,
    specialDefense: 48,
    speed: 48,
  );

  // Dos Pokémon: Bulbasaur con dos tipos y Ditto sin tipos guardados.
  Future<void> guardar() {
    return db.catalogoDao.savePage(
      types: [
        PokeTypesCompanion.insert(id: const Value(12), name: 'grass'),
        PokeTypesCompanion.insert(id: const Value(4), name: 'poison'),
      ],
      pokemons: [pokemon(132, 'ditto'), pokemon(1, 'bulbasaur')],
      pokemonTypes: [
        // Se insertan "al revés" a propósito: el DAO debe ordenar por slot.
        PokemonTypesCompanion.insert(pokemonId: 1, typeId: 4, slot: 2),
        PokemonTypesCompanion.insert(pokemonId: 1, typeId: 12, slot: 1),
      ],
      stats: [statsDitto(), statsBulbasaur()],
      syncState: const SyncMetadataCompanion(
        resourceKey: Value(SyncResources.catalog),
        status: Value(SyncStatus.syncing),
        cursorOrOffset: Value('132'),
      ),
    );
  }

  test('devuelve cada Pokémon una sola vez, ordenado por id', () async {
    await guardar();

    final lista = await db.catalogoDao.watchCatalogWithTypes().first;

    expect(lista.map((e) => e.pokemon.name), ['bulbasaur', 'ditto']);
  });

  test('los tipos vienen ordenados por slot', () async {
    await guardar();

    final lista = await db.catalogoDao.watchCatalogWithTypes().first;

    expect(lista.first.types.map((t) => t.name), ['grass', 'poison']);
  });

  test('un Pokémon sin tipos no desaparece de la lista', () async {
    await guardar();

    final lista = await db.catalogoDao.watchCatalogWithTypes().first;

    expect(lista.last.pokemon.name, 'ditto');
    expect(lista.last.types, isEmpty);
  });

  test('saveSyncState cambia el estado y conserva el cursor', () async {
    await guardar();

    await db.catalogoDao.saveSyncState(
      const SyncMetadataCompanion(
        resourceKey: Value(SyncResources.catalog),
        status: Value(SyncStatus.failed),
      ),
    );
    final estado = await db.catalogoDao.readSyncState(SyncResources.catalog);

    expect(estado!.status, SyncStatus.failed);
    expect(estado.cursorOrOffset, '132');
  });

  test('guarda las seis estadísticas de cada Pokémon', () async {
    await guardar();

    // Lectura directa de la tabla: aún no hay consulta de estadísticas en el DAO.
    final filas = await db.select(db.pokemonStats).get();
    final bulbasaur = filas.firstWhere((f) => f.pokemonId == 1);

    expect(filas, hasLength(2));
    expect(bulbasaur.hp, 45);
    expect(bulbasaur.specialAttack, 65);
    expect(bulbasaur.speed, 45);
  });

  test('sincronizar dos veces no duplica las estadísticas', () async {
    await guardar();
    await guardar();

    final filas = await db.select(db.pokemonStats).get();

    expect(filas, hasLength(2));
  });

  test('una estadística actualizada reemplaza la anterior', () async {
    await guardar();

    // La API cambió el valor de HP de Bulbasaur: el upsert debe sobrescribirlo.
    await db.catalogoDao.savePage(
      types: const [],
      pokemons: const [],
      pokemonTypes: const [],
      stats: [
        PokemonStatsCompanion.insert(
          pokemonId: const Value(1),
          hp: 50,
          attack: 49,
          defense: 49,
          specialAttack: 65,
          specialDefense: 65,
          speed: 45,
        ),
      ],
      syncState: const SyncMetadataCompanion(
        resourceKey: Value(SyncResources.catalog),
        status: Value(SyncStatus.syncing),
        cursorOrOffset: Value('132'),
      ),
    );

    final filas = await db.select(db.pokemonStats).get();
    final bulbasaur = filas.firstWhere((f) => f.pokemonId == 1);

    expect(filas, hasLength(2));
    expect(bulbasaur.hp, 50);
  });
}
