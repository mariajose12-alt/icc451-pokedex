import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    // Los movimientos y los grupos de versión deben existir antes de
    // guardar qué Pokémon los aprende (claves foráneas).
    await db
        .into(db.moves)
        .insert(
          MovesCompanion.insert(id: const Value(14), name: 'swords-dance'),
        );
    await db
        .into(db.versionGroups)
        .insert(
          VersionGroupsCompanion.insert(id: const Value(1), name: 'red-blue'),
        );
  });

  tearDown(() async {
    await db.close();
  });

  PokemonMovesCompanion move({required int level}) {
    return PokemonMovesCompanion.insert(
      pokemonId: 1,
      versionGroupId: 1,
      learnMethodId: 1,
      moveId: 14,
      level: Value(level),
    );
  }

  test('guardar dos veces el mismo movimiento no lo duplica', () async {
    await db.into(db.pokemonMoves).insertOnConflictUpdate(move(level: 20));
    await db.into(db.pokemonMoves).insertOnConflictUpdate(move(level: 20));

    final rows = await db.select(db.pokemonMoves).get();

    expect(rows.length, 1);
  });

  test('un movimiento puede aprenderse en dos niveles distintos', () async {
    await db.into(db.pokemonMoves).insertOnConflictUpdate(move(level: 20));
    await db.into(db.pokemonMoves).insertOnConflictUpdate(move(level: 40));

    final rows = await db.select(db.pokemonMoves).get();

    expect(rows.map((row) => row.level).toSet(), {20, 40});
  });

  test(
    'no se puede guardar un movimiento que no está en el catálogo',
    () async {
      // El movimiento 999 no existe en moves: la clave foránea lo rechaza.
      expect(
        () => db
            .into(db.pokemonMoves)
            .insert(
              PokemonMovesCompanion.insert(
                pokemonId: 1,
                versionGroupId: 1,
                learnMethodId: 1,
                moveId: 999,
              ),
            ),
        throwsA(anything),
      );
    },
  );

  test('las habilidades guardan el nombre en español e inglés', () async {
    await db
        .into(db.abilities)
        .insert(
          AbilitiesCompanion.insert(
            id: const Value(65),
            name: 'overgrow',
            nameEs: const Value('Espesura'),
            nameEn: const Value('Overgrow'),
          ),
        );

    final row = await (db.select(
      db.abilities,
    )..where((a) => a.id.equals(65))).getSingle();

    expect(row.nameEs, 'Espesura');
    expect(row.nameEn, 'Overgrow');
  });

  test(
    'una forma se guarda sin que exista su Pokémon en el catálogo',
    () async {
      // Rattata de Alola (10091) no está en pokemons: no debe fallar.
      await db
          .into(db.pokemonForms)
          .insert(
            PokemonFormsCompanion.insert(
              id: const Value(10091),
              speciesId: 19,
              name: 'rattata-alola',
              isDefault: false,
            ),
          );

      final rows = await db.select(db.pokemonForms).get();

      expect(rows.single.id, 10091);
    },
  );
}
