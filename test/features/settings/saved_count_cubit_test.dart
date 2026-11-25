import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/settings/presentation/cubit/saved_count_cubit.dart';

import '../../helpers/fake_saved_pokemon_repository.dart';

void main() {
  test(
    'muestra el conteo actual y se actualiza cuando la base cambia',
    () async {
      final repository = FakeSavedPokemonRepository(count: 20);
      final cubit = SavedCountCubit(repository: repository);

      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, 20);

      repository.setCount(1025);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, 1025);

      await cubit.close();
    },
  );
}
