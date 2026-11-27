import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  Future<void> insertPokemon(int id, String name) {
    return db
        .into(db.pokemons)
        .insert(
          PokemonsCompanion.insert(
            id: Value(id),
            name: name,
            nationalDexNumber: id,
            generationId: 1,
            updatedAt: DateTime(2026, 10, 25),
          ),
        );
  }

  setUp(() async {
    // Base en memoria nueva en cada test: nada depende de otros tests.
    db = AppDatabase(NativeDatabase.memory());
    await insertPokemon(25, 'pikachu');
    await insertPokemon(4, 'charmander');
  });

  tearDown(() async {
    await db.close();
  });

  test('más reciente primero y trae los datos del Pokémon', () async {
    await db
        .into(db.favorites)
        .insert(
          FavoritesCompanion.insert(
            pokemonId: const Value(25),
            createdAt: Value(DateTime(2026, 11, 1)),
          ),
        );
    await db
        .into(db.favorites)
        .insert(
          FavoritesCompanion.insert(
            pokemonId: const Value(4),
            createdAt: Value(DateTime(2026, 11, 2)),
          ),
        );

    final result = await db.favoritesDao.watchFavoritesWithTypes().first;

    expect(result.map((item) => item.pokemon.name), ['charmander', 'pikachu']);
  });

  test('quitar un favorito lo saca del stream sin volver a pedirlo', () async {
    await db.favoritesDao.toggle(25);
    final emitted = <int>[];
    final sub = db.favoritesDao.watchFavoritesWithTypes().listen(
      (rows) => emitted.add(rows.length),
    );

    await pumpEventQueue();
    await db.favoritesDao.toggle(25);
    await pumpEventQueue();
    await sub.cancel();

    expect(emitted, [1, 0]);
  });

  test('un favorito sin tipos guardados sigue apareciendo', () async {
    await db.favoritesDao.toggle(25);

    final result = await db.favoritesDao.watchFavoritesWithTypes().first;

    expect(result, hasLength(1));
    expect(result.single.types, isEmpty);
  });
}
