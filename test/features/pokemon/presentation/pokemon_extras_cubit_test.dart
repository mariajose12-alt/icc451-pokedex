import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_extras.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_extras_cubit.dart';

import '../../../helpers/fake_pokemon_detail_repository.dart';

void main() {
  late FakePokemonDetailRepository repository;
  late PokemonExtrasCubit cubit;

  setUp(() {
    repository = FakePokemonDetailRepository();
    cubit = PokemonExtrasCubit(repository: repository, pokemonId: 1);
  });

  tearDown(() async {
    await cubit.close();
    await repository.extrasController.close();
  });

  test('empieza vacío y sin descargar', () {
    expect(cubit.state, PokemonExtras.empty);
    expect(cubit.state.downloaded, isFalse);
  });

  test('emite lo que llega de la base', () async {
    repository.extrasController.add(
      const PokemonExtras(downloaded: true, eggGroups: ['monster']),
    );
    await pumpEventQueue();

    expect(cubit.state.downloaded, isTrue);
    expect(cubit.state.eggGroups, ['monster']);
  });

  test('al cerrar, cancela la suscripción', () async {
    expect(repository.extrasController.hasListener, isTrue);

    await cubit.close();

    expect(repository.extrasController.hasListener, isFalse);
  });
}
