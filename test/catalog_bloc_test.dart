import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/errors/failures.dart';
import 'package:pokedex/features/pokemon/data/repositories/fake_pokemon_repository.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_bloc.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_event.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_state.dart';

/// Repositorio que solo cuenta cuántas veces se pidió actualizar.
class _CountingRepository implements PokemonRepository {
  int refreshCalls = 0;

  @override
  Stream<List<Pokemon>> watchCatalog() => const Stream<List<Pokemon>>.empty();

  @override
  Future<void> refreshCatalog({bool onlyIfStale = false}) async {
    refreshCalls++;
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

void main() {
  test(
    'Sin datos y con un fallo: Loading, Failure y, al reintentar, Success',
    () async {
      final bloc = CatalogBloc(
        repository: FakePokemonRepository(
          scenario: FakeScenario.failsOnce,
          delay: Duration.zero,
        ),
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
      final bloc = CatalogBloc(repository: repository);

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
}
