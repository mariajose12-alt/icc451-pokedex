import 'package:drift/drift.dart' show Value, BooleanExpressionOperators;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/features/pokemon/data/datasources/local/pokemon_detail_local_datasource.dart';
import 'package:pokedex/features/pokemon/data/datasources/remote/pokemon_remote_datasource.dart';
import 'package:pokedex/features/pokemon/data/sync/pokemon_detail_sync_coordinator.dart';

import '../../../helpers/fake_detail_api.dart';

void main() {
  late AppDatabase db;
  late PokemonDetailSyncCoordinator coordinator;
  late List<String> logs;
  late DebugPrintCallback originalDebugPrint;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    coordinator = PokemonDetailSyncCoordinator(
      remote: PokemonRemoteDataSource(client: FakeDetailApi()),
      local: PokemonDetailLocalDataSource(dao: db.detalleDao),
      minInterval: Duration.zero,
      retryDelays: const [],
    );
    // Se captura lo que se imprime en consola para comprobar el registro.
    logs = [];
    originalDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) => logs.add(message ?? '');
  });

  tearDown(() async {
    debugPrint = originalDebugPrint;
    await db.close();
  });

  test('si el nombre se altera en la base, se detecta, se registra y se '
      'restaura (PA-16)', () async {
    await coordinator.refresh(1);
    final original = await (db.select(
      db.pokemons,
    )..where((p) => p.id.equals(1))).getSingle();

    await (db.update(db.pokemons)..where((p) => p.id.equals(1))).write(
      const PokemonsCompanion(name: Value('alterado')),
    );
    await coordinator.refresh(1);

    final restored = await (db.select(
      db.pokemons,
    )..where((p) => p.id.equals(1))).getSingle();
    expect(restored.name, original.name);
    expect(logs.any((l) => l.contains('Integridad: #1')), isTrue);
  });

  test('si no hay alteración, no se registra ninguna diferencia', () async {
    await coordinator.refresh(1);
    await coordinator.refresh(1);

    expect(logs.any((l) => l.contains('Integridad')), isFalse);
  });

  test('un tipo alterado en la base se detecta y se restaura', () async {
    await coordinator.refresh(1);
    final original = await db.detalleDao.readBase(1);
    // El Pokémon de prueba tiene 2 tipos guardados: se usa el segundo como
    // valor falso para el slot 1, así la clave foránea siempre existe.
    final otherTypeId = original!.typeIds[1];

    await (db.update(db.pokemonTypes)
      ..where((t) => t.pokemonId.equals(1) & t.slot.equals(1)))
        .write(PokemonTypesCompanion(typeId: Value(otherTypeId)));
    final altered = await db.detalleDao.readBase(1);
    expect(altered!.typeIds, isNot(original.typeIds));

    await coordinator.refresh(1);

    final restored = await db.detalleDao.readBase(1);
    expect(restored!.typeIds, original.typeIds);
    expect(logs.any((l) => l.contains('tipos')), isTrue);
  });
}