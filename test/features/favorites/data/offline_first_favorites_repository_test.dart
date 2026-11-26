import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/features/favorites/data/repositories/offline_first_favorites_repository.dart';

void main() {
  late AppDatabase db;
  late OfflineFirstFavoritesRepository repo;

  setUp(() async {
    // Base de datos en memoria: no toca el disco del teléfono.
    db = AppDatabase(NativeDatabase.memory());
    repo = OfflineFirstFavoritesRepository(dao: db.favoritesDao);

    // El favorito necesita que el Pokémon exista (clave foránea).
    await db
        .into(db.pokemons)
        .insert(
          PokemonsCompanion.insert(
            id: const Value(25),
            nationalDexNumber: 25,
            name: 'pikachu',
            generationId: 1,
            updatedAt: DateTime(2026, 11, 20),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'marcar un favorito llega al stream en menos de 150 ms (RF-FAV-04)',
    () async {
      // El primer valor del stream es false; esperamos el primer true.
      final llegoTrue = repo
          .watchIsFavorite(25)
          .firstWhere((esFavorito) => esFavorito)
          .timeout(const Duration(seconds: 2));

      final cronometro = Stopwatch()..start();
      await repo.toggle(25);
      await llegoTrue;
      cronometro.stop();

      expect(
        cronometro.elapsed,
        lessThan(const Duration(milliseconds: 150)),
        reason: 'Marcar el favorito tardó ${cronometro.elapsedMilliseconds} ms',
      );
    },
  );
}
