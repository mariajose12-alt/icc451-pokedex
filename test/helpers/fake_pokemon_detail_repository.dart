import 'dart:async';

import 'package:pokedex/features/pokemon/domain/entities/pokemon_extras.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_detail_repository.dart';

/// Repositorio falso del detalle: la prueba decide cuándo termina la consulta,
/// si falla, y qué emite la "base".
class FakePokemonDetailRepository implements PokemonDetailRepository {
  /// Ids con los que se pidió refrescar, en orden.
  final List<int> refreshed = <int>[];

  /// Si no es null, refreshDetail espera hasta que se complete.
  Completer<void>? pending;

  /// Si no es null, refreshDetail falla con este error.
  Object? failWith;

  final StreamController<PokemonExtras> extrasController =
      StreamController<PokemonExtras>.broadcast();

  @override
  Future<void> refreshDetail(int pokemonId) async {
    refreshed.add(pokemonId);
    await pending?.future;
    final error = failWith;
    if (error != null) {
      throw error;
    }
  }

  @override
  Stream<PokemonExtras> watchExtras(int pokemonId) => extrasController.stream;
}
