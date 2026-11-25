import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/errors/failures.dart';
import 'package:pokedex/features/pokemon/data/repositories/fake_pokemon_repository.dart';
import 'package:pokedex/features/pokemon/domain/entities/catalogo_query.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_bloc.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_event.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokedex/features/pokemon/data/preferences/catalog_query_store.dart';

/// Repositorio que solo cuenta cuántas veces se pidió actualizar.
class _CountingRepository implements PokemonRepository {
  int refreshCalls = 0;

  @override
  Stream<List<Pokemon>> watchCatalog() => const Stream<List<Pokemon>>.empty();

  @override
  Stream<Pokemon?> watchPokemon(int id) => const Stream<Pokemon?>.empty();

  @override
  Future<void> refreshCatalog({bool onlyIfStale = false}) async {
    refreshCalls++;
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  @override
  Stream<List<Pokemon>> watchCatalogoFiltrado(CatalogoQuery query) =>
      watchCatalog();
}

/// Repositorio que guarda los criterios y el momento en que el Bloc observa la base.
class _QueryRecordingRepository implements PokemonRepository {
  final List<CatalogoQuery> queries = [];
  final List<DateTime> times = [];

  @override
  Stream<List<Pokemon>> watchCatalog() => const Stream<List<Pokemon>>.empty();

  @override
  Stream<Pokemon?> watchPokemon(int id) => const Stream<Pokemon?>.empty();

  @override
  Future<void> refreshCatalog({bool onlyIfStale = false}) async {}

  @override
  Stream<List<Pokemon>> watchCatalogoFiltrado(CatalogoQuery query) {
    queries.add(query);
    times.add(DateTime.now());
    return const Stream<List<Pokemon>>.empty();
  }
}

void main() {
  late CatalogQueryStore queryStore;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    queryStore = CatalogQueryStore(
      preferences: await SharedPreferences.getInstance(),
    );
  });

  test(
    'Sin datos y con un fallo: Loading, Failure y, al reintentar, Success',
    () async {
      final bloc = CatalogBloc(
        repository: FakePokemonRepository(
          scenario: FakeScenario.failsOnce,
          delay: Duration.zero,
        ),
        queryStore: queryStore,
      );
      final states = <CatalogState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const CatalogStarted());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(states.first, isA<CatalogLoading>());
      expect(states.last, isA<CatalogFailure>());

      bloc.add(const CatalogRefreshRequested());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(states.last, isA<CatalogSuccess>());

      await subscription.cancel();
      await bloc.close();
    },
  );

  test(
    'Con datos y un refresco fallido: conserva los datos y avisa (OF-04)',
    () async {
      final bloc = CatalogBloc(
        repository: FakePokemonRepository(
          scenario: FakeScenario.hasDataButFails,
          delay: Duration.zero,
        ),
        queryStore: queryStore,
      );
      final states = <CatalogState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const CatalogStarted());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(states.last, isA<CatalogSuccess>());
      final success = states.last as CatalogSuccess;
      expect(success.pokemon, isNotEmpty);
      expect(success.isRefreshing, isFalse);
      expect(success.refreshFailure, isA<ServiceFailure>());

      await subscription.cancel();
      await bloc.close();
    },
  );

  test('Sin datos y sin fallo: muestra el estado vacío (PA-15)', () async {
    final bloc = CatalogBloc(
      repository: FakePokemonRepository(
        scenario: FakeScenario.empty,
        delay: Duration.zero,
      ),
      queryStore: queryStore,
    );
    final states = <CatalogState>[];
    final subscription = bloc.stream.listen(states.add);

    bloc.add(const CatalogStarted());
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(states.last, isA<CatalogEmpty>());

    await subscription.cancel();
    await bloc.close();
  });

  test(
    'Varios refrescos seguidos solo hacen una llamada (droppable)',
    () async {
      final repository = _CountingRepository();
      final bloc = CatalogBloc(repository: repository, queryStore: queryStore);

      bloc.add(const CatalogStarted());
      bloc
        ..add(const CatalogRefreshRequested())
        ..add(const CatalogRefreshRequested())
        ..add(const CatalogRefreshRequested());
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(repository.refreshCalls, 1);

      // Cuando la anterior terminó, un refresco nuevo sí se ejecuta.
      bloc.add(const CatalogRefreshRequested());
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(repository.refreshCalls, 2);

      await bloc.close();
    },
  );

  test('escribir rápido aplica solo el texto final, tras la pausa', () async {
    final repo = _QueryRecordingRepository();
    final bloc = CatalogBloc(repository: repo, queryStore: queryStore);

    bloc.add(const CatalogStarted());
    await Future<void>.delayed(const Duration(milliseconds: 20));
    repo.queries.clear();
    repo.times.clear();

    // Simula escribir "pika" con 50 ms entre teclas (menos que el debounce).
    DateTime? ultimaTecla;
    for (final texto in ['p', 'pi', 'pik', 'pika']) {
      ultimaTecla = DateTime.now();
      bloc.add(CatalogSearchChanged(texto));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }

    // Espera a que el debounce termine y el Bloc aplique la búsqueda.
    await Future<void>.delayed(const Duration(milliseconds: 1000));

    // Solo debe consultarse el texto final.
    expect(repo.queries.length, 1);
    expect(repo.queries.single.nombre, 'pika');

    // Debe aplicarse poco después de la última tecla (debounce de 350 ms).
    expect(
      repo.times.single.difference(ultimaTecla!),
      lessThan(const Duration(milliseconds: 500)),
    );

    await bloc.close();
  });

  test('al abrir, el Bloc usa el criterio que se guardó antes', () async {
    const guardado = CatalogoQuery(tipoIds: {13}, orden: CatalogoOrden.nombre);
    await queryStore.save(guardado);

    final repo = _QueryRecordingRepository();
    final bloc = CatalogBloc(repository: repo, queryStore: queryStore);

    bloc.add(const CatalogStarted());
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(repo.queries.last, guardado);

    await bloc.close();
  });
}
