import 'dart:async';

import 'package:pokedex/features/pokemon/domain/entities/move_learn_method.dart';
import 'package:pokedex/features/pokemon/domain/entities/move_version_group.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_move.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_moves_repository.dart';

/// Repositorio falso: las pruebas empujan datos por los controllers y miran
/// qué versión y método se pidieron.
class FakePokemonMovesRepository implements PokemonMovesRepository {
  final groupsController = StreamController<List<MoveVersionGroup>>.broadcast();
  final movesController = StreamController<List<PokemonMove>>.broadcast();

  /// Cada llamada a watchMoves: (versionGroupId, método).
  final requests = <(int, MoveLearnMethod)>[];

  @override
  Stream<List<MoveVersionGroup>> watchVersionGroups(int pokemonId) {
    return groupsController.stream;
  }

  @override
  Stream<List<PokemonMove>> watchMoves({
    required int pokemonId,
    required int versionGroupId,
    required MoveLearnMethod method,
  }) {
    requests.add((versionGroupId, method));
    return movesController.stream;
  }

  Future<void> dispose() async {
    await groupsController.close();
    await movesController.close();
  }
}
