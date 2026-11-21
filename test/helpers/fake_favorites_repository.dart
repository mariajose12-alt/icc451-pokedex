import 'dart:async';

import 'package:pokedex/features/favorites/domain/repositories/favorites_repository.dart';

/// Repositorio falso: guarda los favoritos en memoria y avisa por un stream.
class FakeFavoritesRepository implements FavoritesRepository {
  final _ids = <int>{};
  final _controller = StreamController<Set<int>>.broadcast();
  int toggleCalls = 0;

  @override
  Stream<bool> watchIsFavorite(int pokemonId) async* {
    yield _ids.contains(pokemonId);
    yield* _controller.stream.map((ids) => ids.contains(pokemonId)).distinct();
  }

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
