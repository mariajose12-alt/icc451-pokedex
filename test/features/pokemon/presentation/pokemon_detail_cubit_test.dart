import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_type.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_detail_cubit.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_detail_state.dart';

import '../../../helpers/controllable_pokemon_repository.dart';

const Pokemon _bulbasaur = Pokemon(
  id: 1,
  name: 'bulbasaur',
  nationalDexNumber: 1,
  generationId: 1,
  height: 7,
  weight: 69,
  types: [PokemonType(id: 12, name: 'grass')],
);

void main() {
  late ControllablePokemonRepository repository;
  late PokemonDetailCubit cubit;

  setUp(() {
    repository = ControllablePokemonRepository();
    cubit = PokemonDetailCubit(repository: repository, pokemonId: 1);
  });

  tearDown(() async {
    await cubit.close();
    await repository.pokemonController.close();
  });

  test('pide al repositorio el id que recibió', () {
    expect(repository.lastRequestedId, 1);
  });

  test('empieza en Loading, antes de que la base responda', () {
    expect(cubit.state, isA<PokemonDetailLoading>());
  });

  test('un Pokémon guardado produce Success con ese Pokémon', () async {
    repository.pokemonController.add(_bulbasaur);
    await pumpEventQueue();

    expect(cubit.state, const PokemonDetailSuccess(_bulbasaur));
  });

  test('null (no está guardado) produce NotFound', () async {
    repository.pokemonController.add(null);
    await pumpEventQueue();

    expect(cubit.state, isA<PokemonDetailNotFound>());
  });

  test(
    'si la base cambia, emite un Success nuevo con los datos nuevos',
    () async {
      final states = <PokemonDetailState>[];
      final subscription = cubit.stream.listen(states.add);
      addTearDown(subscription.cancel);

      repository.pokemonController.add(_bulbasaur);
      await pumpEventQueue();

      // Mismo Pokémon, pero con el nombre cambiado (como una restauración).
      const renombrado = Pokemon(
        id: 1,
        name: 'ivysaur',
        nationalDexNumber: 1,
        generationId: 1,
        height: 7,
        weight: 69,
        types: [PokemonType(id: 12, name: 'grass')],
      );
      repository.pokemonController.add(renombrado);
      await pumpEventQueue();

      expect(states.last, const PokemonDetailSuccess(renombrado));
    },
  );

  test('al cerrarse deja de escuchar la base', () async {
    expect(repository.pokemonController.hasListener, isTrue);

    await cubit.close();

    expect(repository.pokemonController.hasListener, isFalse);
  });
}
