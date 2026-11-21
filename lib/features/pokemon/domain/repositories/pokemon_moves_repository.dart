import 'package:pokedex/features/pokemon/domain/entities/move_learn_method.dart';
import 'package:pokedex/features/pokemon/domain/entities/move_version_group.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_move.dart';

/// Movimientos de un Pokémon (RF-DET-05). Solo lee de la base local: los
/// datos llegan cuando se descarga el detalle.
abstract class PokemonMovesRepository {
  /// Versiones en las que el Pokémon tiene movimientos, de la más nueva a
  /// la más antigua.
  Stream<List<MoveVersionGroup>> watchVersionGroups(int pokemonId);

  /// Movimientos de una versión y un método.
  Stream<List<PokemonMove>> watchMoves({
    required int pokemonId,
    required int versionGroupId,
    required MoveLearnMethod method,
  });
}
