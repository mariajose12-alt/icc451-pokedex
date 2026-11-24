import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());

    // favorites tiene clave foránea a pokemons: primero existen los Pokémon.
    for (final (id, name) in [(1, 'bulbasaur'), (4, 'charmander')]) {
      await db
          .into(db.pokemons)
          .insert(
            PokemonsCompanion.insert(
              id: Value(id),
              name: name,
              nationalDexNumber: id,
              generationId: 1,
              updatedAt: DateTime(2026, 11, 21),
            ),
          );
    }
  });

  tearDown(() async {
    await db.close();
  });

  test('toggle agrega y la segunda vez quita', () async {
    expect(await db.favoritesDao.toggle(1), isTrue);
    expect(await db.favoritesDao.watchIsFavorite(1).first, isTrue);

    expect(await db.favoritesDao.toggle(1), isFalse);
    expect(await db.favoritesDao.watchIsFavorite(1).first, isFalse);
  });

  test('un favorito no afecta a los demás Pokémon', () async {
    await db.favoritesDao.toggle(1);

    expect(await db.favoritesDao.watchIsFavorite(4).first, isFalse);
    expect(await db.favoritesDao.watchFavoriteIds().first, {1});
  });

  test('un Pokémon solo puede ser favorito una vez (PS-06)', () async {
    await db.favoritesDao.toggle(1);
    await db.favoritesDao.toggle(1);
    await db.favoritesDao.toggle(1);

    final rows = await db.select(db.favorites).get();
    expect(rows.length, 1);
  });

  test('el stream avisa cuando cambia el favorito', () async {
    final values = <bool>[];
    final subscription = db.favoritesDao.watchIsFavorite(1).listen(values.add);

    await pumpEventQueue();
    await db.favoritesDao.toggle(1);
    await pumpEventQueue();
    await db.favoritesDao.toggle(1);
    await pumpEventQueue();
    await subscription.cancel();

    expect(values, [false, true, false]);
  });

  test('guardar un favorito tarda menos de 150 ms (RF-FAV-04)', () async {
    final stopwatch = Stopwatch()..start();
    await db.favoritesDao.toggle(1);
    stopwatch.stop();

    expect(stopwatch.elapsedMilliseconds, lessThan(150));
  });
}
