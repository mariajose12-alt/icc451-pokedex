import 'dart:async';

import 'package:pokedex/features/settings/domain/repositories/saved_pokemon_repository.dart';

/// Repositorio falso: el conteo y los sprites se definen a mano.
class FakeSavedPokemonRepository implements SavedPokemonRepository {
  FakeSavedPokemonRepository({this._count = 0, this.sprites = const []});

  final List<String> sprites;
  final StreamController<int> _changes = StreamController<int>.broadcast();
  int _count;

  /// Simula que la base cambió.
  void setCount(int value) {
    _count = value;
    _changes.add(value);
  }

  @override
  Stream<int> watchCount() async* {
    yield _count;
    yield* _changes.stream;
  }

  @override
  Future<List<String>> randomSpriteUrls(int limit) async =>
      sprites.take(limit).toList();
}
