import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/favorites/presentation/cubit/favorites_cubit.dart';

import '../../helpers/fake_favorites_repository.dart';

void main() {
  late FakeFavoritesRepository repository;
  late FavoriteCubit cubit;

  setUp(() {
    repository = FakeFavoritesRepository();
    cubit = FavoriteCubit(repository: repository, pokemonId: 1);
  });

  tearDown(() async {
    await cubit.close();
    await repository.dispose();
  });

  test('empieza sin ser favorito', () async {
    await pumpEventQueue();

    expect(cubit.state, isFalse);
  });

  test('toggle cambia el estado cuando la base avisa', () async {
    await pumpEventQueue();

    await cubit.toggle();
    await pumpEventQueue();

    expect(cubit.state, isTrue);
    expect(repository.toggleCalls, 1);

    await cubit.toggle();
    await pumpEventQueue();

    expect(cubit.state, isFalse);
  });

  test('el estado no cambia hasta que la base avisa', () async {
    await pumpEventQueue();

    final future = cubit.toggle();

    // Antes de que el stream emita, el cubit sigue como estaba.
    expect(cubit.state, isFalse);
    await future;
  });
}
