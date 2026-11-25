import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';

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
      syncState: const SyncMetadataCompanion(
        resourceKey: Value('catalog'),
        status: Value('syncing'),
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
        resourceKey: Value('catalog'),
        status: Value('failed'),
      ),
    );
    final estado = await db.catalogoDao.readSyncState('catalog');

    expect(estado!.status, 'failed');
    expect(estado.cursorOrOffset, '132');
  });
}
