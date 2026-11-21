import 'package:pokedex/core/database/app_database.dart';
import 'package:pokedex/core/database/daos/detalle_dao.dart';

/// Lee los movimientos de la base local. No sabe nada del dominio.
class PokemonMovesLocalDataSource {
  const PokemonMovesLocalDataSource({required this._dao});

  final DetalleDao _dao;

  Stream<List<VersionGroupEntry>> watchVersionGroups(int pokemonId) {
    return _dao.watchMoveVersionGroups(pokemonId);
  }

  Stream<List<MoveRow>> watchMoves({
    required int pokemonId,
    required int versionGroupId,
    required int learnMethodId,
  }) {
    return _dao.watchMoves(
      pokemonId: pokemonId,
      versionGroupId: versionGroupId,
      learnMethodId: learnMethodId,
    );
  }
}
