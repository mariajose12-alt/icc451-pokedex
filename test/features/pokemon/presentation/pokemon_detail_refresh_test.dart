import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_type.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_detail_cubit.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_detail_state.dart';

import '../../../helpers/controllable_pokemon_repository.dart';
import '../../../helpers/fake_pokemon_detail_repository.dart';

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
  late FakePokemonDetailRepository detailRepository;
  late PokemonDetailCubit cubit;

  PokemonDetailCubit build({int id = 1}) {
    return PokemonDetailCubit(
      repository: repository,
      pokemonId: id,
      detailRepository: detailRepository,
    );
  }

  setUp(() {
    repository = ControllablePokemonRepository();
    detailRepository = FakePokemonDetailRepository();
  });

  tearDown(() async {
    await cubit.close();
    await repository.pokemonController.close();
    await detailRepository.extrasController.close();
  });

  test('al abrirse pide actualizar el detalle (OF-20)', () async {
    cubit = build();
    await pumpEventQueue();

    expect(detailRepository.refreshed, [1]);
  });

  test('un id inválido no consulta a PokeAPI', () async {
    cubit = build(id: -1);
    repository.pokemonController.add(null);
    await pumpEventQueue();

    expect(detailRepository.refreshed, isEmpty);
    expect(cubit.state, isA<PokemonDetailNotFound>());
  });

  test(
    'no guardado: espera la consulta y luego muestra el Pokémon (PA-02)',
    () async {
      detailRepository.pending = Completer<void>();
      cubit = build();

      // La base todavía no lo tiene: sigue cargando, NO "no encontrado".
      repository.pokemonController.add(null);
      await pumpEventQueue();
      expect(cubit.state, isA<PokemonDetailLoading>());

      // La consulta termina, se guarda y la base emite el Pokémon.
      detailRepository.pending!.complete();
      repository.pokemonController.add(_bulbasaur);
      await pumpEventQueue();

      expect(cubit.state, const PokemonDetailSuccess(_bulbasaur));
    },
  );

  test('no guardado y la consulta falla: pasa a "no encontrado"', () async {
    detailRepository.pending = Completer<void>();
    detailRepository.failWith = Exception('sin conexión');
    cubit = build();

    repository.pokemonController.add(null);
    await pumpEventQueue();
    expect(cubit.state, isA<PokemonDetailLoading>());

    detailRepository.pending!.complete();
    await pumpEventQueue();

    expect(cubit.state, isA<PokemonDetailNotFound>());
  });

  test('guardado y la consulta falla: sigue mostrando el Pokémon', () async {
    detailRepository.failWith = Exception('sin conexión');
    cubit = build();

    repository.pokemonController.add(_bulbasaur);
    await pumpEventQueue();

    expect(cubit.state, const PokemonDetailSuccess(_bulbasaur));
  });

  test(
    'sin repositorio de detalle conserva el comportamiento anterior',
    () async {
      cubit = PokemonDetailCubit(repository: repository, pokemonId: 1);
      repository.pokemonController.add(null);
      await pumpEventQueue();

      expect(cubit.state, isA<PokemonDetailNotFound>());
    },
  );
}
