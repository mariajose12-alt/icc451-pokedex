import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/data/fake_pokemon_repository.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_bloc.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_event.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_state.dart';

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
}
