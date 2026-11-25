import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/features/pokemon/domain/entities/catalogo_query.dart';
import 'package:pokedex/core/sync/sync_status.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await _guardarCatalogoDePrueba(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<List<String>> nombres(CatalogoQuery query) async {
    final lista = await db.catalogoDao.watchCatalogoFiltrado(query).first;
    return lista.map((p) => p.pokemon.name).toList();
  }

  test('la búsqueda por nombre encuentra coincidencias parciales', () async {
    expect(await nombres(const CatalogoQuery(nombre: 'sau')), ['bulbasaur']);
  });

  test('el filtro por tipo devuelve solo los Pokémon de ese tipo', () async {
    // 10 = fire: solo Charmander.
    expect(await nombres(const CatalogoQuery(tipoIds: {10})), ['charmander']);
  });

  test('un Pokémon con dos tipos que coinciden aparece una sola vez', () async {
    // Bulbasaur es grass (12) y poison (4). Pedir ambos no debe duplicarlo.
    final resultado = await nombres(const CatalogoQuery(tipoIds: {12, 4}));

    expect(resultado.where((n) => n == 'bulbasaur'), hasLength(1));
  });

  test('el filtro por generación devuelve solo esa generación', () async {
    expect(
      await nombres(const CatalogoQuery(generacionIds: {2})),
      ['chikorita'],
    );
  });

  test('los filtros se combinan: tipo y generación', () async {
    // Grass en generación 1: Bulbasaur, pero no Chikorita (generación 2).
    expect(
      await nombres(
        const CatalogoQuery(tipoIds: {12}, generacionIds: {1}),
      ),
      ['bulbasaur'],
    );
  });

  test('el orden por número va de menor a mayor', () async {
    expect(
      await nombres(const CatalogoQuery(orden: CatalogoOrden.numero)),
      ['bulbasaur', 'charmander', 'pikachu', 'chikorita'],
    );
  });

  test('el orden por nombre va en orden alfabético', () async {
    expect(
      await nombres(const CatalogoQuery(orden: CatalogoOrden.nombre)),
      ['bulbasaur', 'charmander', 'chikorita', 'pikachu'],
    );
  });

  test('el orden por total base va de mayor a menor', () async {
    // Pikachu 320, Bulbasaur 318 y Chikorita 318 (empate), Charmander 309.
    final resultado = await nombres(
      const CatalogoQuery(orden: CatalogoOrden.totalBase),
    );

    expect(resultado.first, 'pikachu');
    expect(resultado.last, 'charmander');
  });
}

/// Cuatro Pokémon con tipos y stats reales de PokeAPI.
Future<void> _guardarCatalogoDePrueba(AppDatabase db) {
  return db.catalogoDao.savePage(
    types: [
      PokeTypesCompanion.insert(id: const Value(4), name: 'poison'),
      PokeTypesCompanion.insert(id: const Value(10), name: 'fire'),
      PokeTypesCompanion.insert(id: const Value(12), name: 'grass'),
      PokeTypesCompanion.insert(id: const Value(13), name: 'electric'),
    ],
    pokemons: [
      _pokemon(1, 'bulbasaur', generacion: 1),
      _pokemon(4, 'charmander', generacion: 1),
      _pokemon(25, 'pikachu', generacion: 1),
      _pokemon(152, 'chikorita', generacion: 2),
    ],
    pokemonTypes: [
      PokemonTypesCompanion.insert(pokemonId: 1, typeId: 12, slot: 1),
      PokemonTypesCompanion.insert(pokemonId: 1, typeId: 4, slot: 2),
      PokemonTypesCompanion.insert(pokemonId: 4, typeId: 10, slot: 1),
      PokemonTypesCompanion.insert(pokemonId: 25, typeId: 13, slot: 1),
      PokemonTypesCompanion.insert(pokemonId: 152, typeId: 12, slot: 1),
    ],
    stats: [
      ..._stats(1, [45, 49, 49, 65, 65, 45]), // total 318
      ..._stats(4, [39, 52, 43, 60, 50, 65]), // total 309
      ..._stats(25, [35, 55, 40, 50, 50, 90]), // total 320
      ..._stats(152, [45, 49, 65, 49, 65, 45]), // total 318
    ],
    syncState: const SyncMetadataCompanion(
      resourceKey: Value(SyncResources.catalog),
      status: Value(SyncStatus.ok),
      cursorOrOffset: Value('152'),
    ),
  );
}

PokemonsCompanion _pokemon(int id, String name, {required int generacion}) {
  return PokemonsCompanion.insert(
    id: Value(id),
    name: name,
    nationalDexNumber: id,
    generationId: generacion,
    updatedAt: DateTime(2026, 11, 24),
  );
}

/// Seis filas, una por stat (statId 1 a 6), como las guarda la tabla.
List<PokemonStatsCompanion> _stats(int pokemonId, List<int> valores) {
  return [
    for (var i = 0; i < valores.length; i++)
      PokemonStatsCompanion.insert(
        pokemonId: pokemonId,
        statId: i + 1,
        baseStat: valores[i],
      ),
  ];
}