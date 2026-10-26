import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  // Antes de cada test: una base de datos nueva, vacía y en memoria.
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  // Después de cada test: cerrar la conexión.
  tearDown(() async {
    await db.close();
  });

  test('guarda un Pokémon y lo lee de vuelta', () async {
    await db.into(db.pokemon).insert(
      PokemonCompanion.insert(
        id: const Value(25),
        name: 'pikachu',
        nationalDexNumber: 25,
        updatedAt: DateTime(2026, 10, 25),
      ),
    );

    final resultados = await db.select(db.pokemon).get();

    expect(resultados.length, 1);
    expect(resultados.first.name, 'pikachu');
    expect(resultados.first.nationalDexNumber, 25);
  });

  test('rechaza un número de Pokédex duplicado (PS-06)', () async {
    await db.into(db.pokemon).insert(
      PokemonCompanion.insert(
        id: const Value(25),
        name: 'pikachu',
        nationalDexNumber: 25,
        updatedAt: DateTime(2026, 10, 25),
      ),
    );

    expect(
          () => db.into(db.pokemon).insert(
        PokemonCompanion.insert(
          id: const Value(26),
          name: 'otro',
          nationalDexNumber: 25,
          updatedAt: DateTime(2026, 10, 25),
        ),
      ),
      throwsException,
    );
  });
}