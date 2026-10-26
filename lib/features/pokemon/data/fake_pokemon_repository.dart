import 'dart:async';

import 'package:pokedex/core/errors/failures.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_type.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_repository.dart';

/// Escenarios que simula el repositorio falso.
enum FakeScenario {
  /// Base vacía; la actualización llena el catálogo.
  success,

  /// Base vacía; la actualización termina sin datos.
  empty,

  /// Base vacía; la primera actualización falla y la segunda funciona.
  failsOnce,

  /// Ya hay datos; la actualización siempre falla.
  hasDataButFails,
}

/// TEMPORAL: repositorio con datos de ejemplo para avanzar la interfaz.
/// Se elimina en T-017, cuando se conecte el repositorio real.
class FakePokemonRepository implements PokemonRepository {
  FakePokemonRepository({
    required this.scenario,
    this.delay = const Duration(milliseconds: 1500),
  }) {
    if (scenario == FakeScenario.hasDataButFails) {
      _data = _sample;
    }
  }

  final FakeScenario scenario;
  final Duration delay;

  List<Pokemon> _data = const [];
  bool _alreadyFailed = false;
  final _changes = StreamController<List<Pokemon>>.broadcast();

  static const List<Pokemon> _sample = [
    Pokemon(
      id: 1,
      name: 'bulbasaur',
      nationalDexNumber: 1,
      generationId: 1,
      height: 7,
      weight: 69,
      types: [
        PokemonType(id: 12, name: 'grass'),
        PokemonType(id: 4, name: 'poison'),
      ],
      artworkUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png',
      spriteUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png',
    ),
    Pokemon(
      id: 4,
      name: 'charmander',
      nationalDexNumber: 4,
      generationId: 1,
      height: 6,
      weight: 85,
      types: [PokemonType(id: 10, name: 'fire')],
      artworkUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/4.png',
      spriteUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/4.png',
    ),
    Pokemon(
      id: 5,
      name: 'charmeleon',
      nationalDexNumber: 5,
      generationId: 1,
      height: 11,
      weight: 190,
      types: [PokemonType(id: 10, name: 'fire')],
    ),
  ];

  @override
  Stream<List<Pokemon>> watchCatalog() async* {
    // Como Drift: primero emite lo que hay y luego cada cambio.
    yield _data;
    yield* _changes.stream;
  }

  @override
  Future<void> refreshCatalog() async {
    await Future<void>.delayed(delay);

    switch (scenario) {
      case FakeScenario.success:
        _data = _sample;
        _changes.add(_data);
      case FakeScenario.empty:
        break;
      case FakeScenario.failsOnce:
        if (!_alreadyFailed) {
          _alreadyFailed = true;
          throw const NoConnectionFailure();
        }
        _data = _sample;
        _changes.add(_data);
      case FakeScenario.hasDataButFails:
        throw const ServiceFailure();
    }
  }
}
