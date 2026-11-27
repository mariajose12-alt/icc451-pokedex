import 'dart:async';

import 'package:pokedex/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';

/// Repositorio falso: guarda los favoritos en memoria y avisa por un stream.
class FakeFavoritesRepository implements FavoritesRepository {
  FakeFavoritesRepository({this.catalog = const <int, Pokemon>{}});

  /// Datos de los Pokémon que el fake sabe devolver en watchFavorites().
  final Map<int, Pokemon> catalog;
  final _ids = <int>{};
  final _controller = StreamController<Set<int>>.broadcast();
  int toggleCalls = 0;

  @override
  Stream<bool> watchIsFavorite(int pokemonId) async* {
    yield _ids.contains(pokemonId);
    yield* _controller.stream.map((ids) => ids.contains(pokemonId)).distinct();
  }

  @override
  Stream<List<Pokemon>> watchFavorites() async* {
    yield _current();
    yield* _controller.stream.map((_) => _current());
  }

  // El último que se agregó va primero, igual que la base real.
  List<Pokemon> _current() => [
    for (final id in _ids.toList().reversed) ?catalog[id],
  ];

  @override
  Stream<Set<int>> watchFavoriteIds() async* {
    yield Set<int>.of(_ids);
    yield* _controller.stream;
  }

  @override
  Future<bool> toggle(int pokemonId) async {
    toggleCalls++;
    if (!_ids.remove(pokemonId)) {
      _ids.add(pokemonId);
    }
    _controller.add(Set<int>.of(_ids));
    return _ids.contains(pokemonId);
  }

  Future<void> dispose() => _controller.close();
}
