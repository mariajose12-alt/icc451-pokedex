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

  // Página de prueba: un Pokémon con un tipo.
  Future<void> guardarPagina() {
    return db.catalogoDao.savePage(
      types: [PokeTypesCompanion.insert(id: const Value(13), name: 'electric')],
      pokemons: [
        PokemonsCompanion.insert(
          id: const Value(25),
          name: 'pikachu',
          nationalDexNumber: 25,
          generationId: 1,
          updatedAt: DateTime(2026, 10, 26),
        ),
      ],
      pokemonTypes: [
        PokemonTypesCompanion.insert(pokemonId: 25, typeId: 13, slot: 1),
      ],
      syncState: SyncMetadataCompanion(
        resourceKey: const Value('catalog'),
        status: const Value('ok'),
        lastSuccessfulAt: Value(DateTime(2026, 10, 26)),
        cursorOrOffset: const Value('25'),
      ),
    );
  }

  test(
    'guardar la misma página tres veces no duplica registros (PA-13)',
    () async {
      await guardarPagina();
      await guardarPagina();
      await guardarPagina();

      expect(await db.catalogoDao.watchCount().first, 1);
      expect(await db.catalogoDao.watchTypesOf(25).first, hasLength(1));
    },
  );

  test('el stream emite cuando se guarda una página (OF-16)', () async {
    final emisiones = <List<PokemonEntry>>[];
    final suscripcion = db.catalogoDao.watchPokemons().listen(emisiones.add);

    // Dejamos que el stream emita su valor inicial (lista vacía).
    await Future<void>.delayed(Duration.zero);

    await guardarPagina();

    // Dejamos que llegue la emisión del cambio.
    await Future<void>.delayed(Duration.zero);
    await suscripcion.cancel();

    expect(emisiones.first, isEmpty);
    expect(emisiones.last, hasLength(1));
    expect(emisiones.last.first.name, 'pikachu');
  });

  test('el estado de sincronización se guarda junto con la página', () async {
    await guardarPagina();

    final estado = await db.catalogoDao.watchSyncState('catalog').first;

    expect(estado, isNotNull);
    expect(estado!.cursorOrOffset, '25');
    expect(estado.status, 'ok');
  });

  test('guarda la ruta local de la imagen de un Pokémon', () async {
    await guardarPagina();

    final filas = await db.catalogoDao.saveArtworkLocalPath(
      25,
      '/data/pokedexImages/25.png',
    );
    final pokemon = await db.catalogoDao.watchPokemons().first;

    expect(filas, 1);
    expect(pokemon.first.artworkLocalPath, '/data/pokedexImages/25.png');
  });
}
