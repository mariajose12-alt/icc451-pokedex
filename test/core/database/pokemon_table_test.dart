import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  // Antes de cada test: base de datos nueva, vacía y en memoria.
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  // Después de cada test: cerrar la conexión.
  tearDown(() async {
    await db.close();
  });

  test('guarda un Pokémon y lo lee de vuelta', () async {
    await db.into(db.pokemons).insert(
      PokemonsCompanion.insert(
        id: const Value(25),
        name: 'pikachu',
        nationalDexNumber: 25,
        generationId: 1,
        updatedAt: DateTime(2026, 10, 25),
      ),
    );

    final resultados = await db.select(db.pokemons).get();

    expect(resultados.length, 1);
    expect(resultados.first.name, 'pikachu');
    expect(resultados.first.nationalDexNumber, 25);
  });

  test('rechaza un número de Pokédex duplicado (PS-06)', () async {
    await db.into(db.pokemons).insert(
      PokemonsCompanion.insert(
        id: const Value(25),
        name: 'pikachu',
        nationalDexNumber: 25,
        generationId: 1,
        updatedAt: DateTime(2026, 10, 25),
      ),
    );

    await expectLater(
      db.into(db.pokemons).insert(
        PokemonsCompanion.insert(
          id: const Value(26),
          name: 'otro',
          nationalDexNumber: 25,
          generationId: 1,
          updatedAt: DateTime(2026, 10, 25),
        ),
      ),
      throwsA(anything),
    );
  });

  test('upsert por id: insertar 3 veces no duplica (PS-06, PA-13)', () async {
    for (var i = 0; i < 3; i++) {
      await db.into(db.pokemons).insertOnConflictUpdate(
        PokemonsCompanion.insert(
          id: const Value(25),
          name: 'pikachu',
          nationalDexNumber: 25,
          generationId: 1,
          updatedAt: DateTime(2026, 10, 25),
        ),
      );
    }

    final resultados = await db.select(db.pokemons).get();

    expect(resultados.length, 1);
  });

  test('borrar un Pokémon borra sus tipos (ON DELETE CASCADE)', () async {
    await db.into(db.pokemons).insert(
      PokemonsCompanion.insert(
        id: const Value(25),
        name: 'pikachu',
        nationalDexNumber: 25,
        generationId: 1,
        updatedAt: DateTime(2026, 10, 25),
      ),
    );
    await db.into(db.pokeTypes).insert(
      PokeTypesCompanion.insert(id: const Value(13), name: 'electric'),
    );
    await db.into(db.pokemonTypes).insert(
      PokemonTypesCompanion.insert(pokemonId: 25, typeId: 13, slot: 1),
    );

    await (db.delete(db.pokemons)..where((p) => p.id.equals(25))).go();

    final relaciones = await db.select(db.pokemonTypes).get();

    expect(relaciones, isEmpty);
  });
}