import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());

    // Versiones: 1 antigua, 5 media, 20 reciente.
    for (final (id, name) in [
      (1, 'red-blue'),
      (5, 'gold-silver'),
      (20, 'sword-shield'),
    ]) {
      await db
          .into(db.versionGroups)
          .insert(VersionGroupsCompanion.insert(id: Value(id), name: name));
    }

    for (final (id, name) in [(1, 'tackle'), (2, 'vine-whip'), (3, 'cut')]) {
      await db
          .into(db.moves)
          .insert(MovesCompanion.insert(id: Value(id), name: name));
    }

    // (pokemon, versión, método, movimiento, nivel)
    for (final (pokemon, version, method, move, level) in [
      (1, 20, 1, 1, 1),
      (1, 20, 1, 2, 3),
      (1, 20, 4, 3, 0),
      (1, 1, 1, 1, 1),
      (2, 5, 1, 1, 1),
    ]) {
      await db
          .into(db.pokemonMoves)
          .insert(
            PokemonMovesCompanion.insert(
              pokemonId: pokemon,
              versionGroupId: version,
              learnMethodId: method,
              moveId: move,
              level: Value(level),
            ),
          );
    }
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'las versiones de un Pokémon van de la más nueva a la más antigua',
    () async {
      final groups = await db.detalleDao.watchMoveVersionGroups(1).first;

      expect([for (final g in groups) g.id], [20, 1]);
    },
  );

  test('las versiones de un Pokémon no incluyen las de otro', () async {
    final groups = await db.detalleDao.watchMoveVersionGroups(2).first;

    expect([for (final g in groups) g.id], [5]);
  });

  test('filtra por versión y método', () async {
    final levelUp = await db.detalleDao
        .watchMoves(pokemonId: 1, versionGroupId: 20, learnMethodId: 1)
        .first;
    final machine = await db.detalleDao
        .watchMoves(pokemonId: 1, versionGroupId: 20, learnMethodId: 4)
        .first;

    expect([for (final m in levelUp) m.name]..sort(), ['tackle', 'vine-whip']);
    expect([for (final m in machine) m.name], ['cut']);
  });

  test('trae el nivel de cada movimiento', () async {
    final rows = await db.detalleDao
        .watchMoves(pokemonId: 1, versionGroupId: 20, learnMethodId: 1)
        .first;

    final vineWhip = rows.firstWhere((m) => m.name == 'vine-whip');
    expect(vineWhip.level, 3);
  });

  test('un Pokémon o una versión sin movimientos da lista vacía', () async {
    final none = await db.detalleDao
        .watchMoves(pokemonId: 99, versionGroupId: 20, learnMethodId: 1)
        .first;

    expect(none, isEmpty);
  });

  test('el stream avisa cuando se guardan movimientos nuevos', () async {
    final stream = db.detalleDao.watchMoves(
      pokemonId: 2,
      versionGroupId: 20,
      learnMethodId: 1,
    );
    final future = stream
        .firstWhere((rows) => rows.isNotEmpty)
        .timeout(const Duration(seconds: 5));

    await db
        .into(db.pokemonMoves)
        .insert(
          PokemonMovesCompanion.insert(
            pokemonId: 2,
            versionGroupId: 20,
            learnMethodId: 1,
            moveId: 2,
            level: const Value(5),
          ),
        );

    final rows = await future;
    expect(rows.single.name, 'vine-whip');
  });
}
