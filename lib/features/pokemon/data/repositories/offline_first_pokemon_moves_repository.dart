import 'package:pokedex/features/pokemon/data/datasources/local/pokemon_moves_local_datasource.dart';
import 'package:pokedex/features/pokemon/domain/entities/move_learn_method.dart';
import 'package:pokedex/features/pokemon/domain/entities/move_version_group.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_move.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_moves_repository.dart';

/// Convierte las filas de la base en entidades del dominio.
class OfflineFirstPokemonMovesRepository implements PokemonMovesRepository {
  const OfflineFirstPokemonMovesRepository({required this._local});

  final PokemonMovesLocalDataSource _local;

  @override
  Stream<List<MoveVersionGroup>> watchVersionGroups(int pokemonId) {
    return _local
        .watchVersionGroups(pokemonId)
        .map(
          (rows) => [
            for (final row in rows)
              MoveVersionGroup(id: row.id, name: row.name),
          ],
        );
  }

  @override
  Stream<List<PokemonMove>> watchMoves({
    required int pokemonId,
    required int versionGroupId,
    required MoveLearnMethod method,
  }) {
    return _local
        .watchMoves(
          pokemonId: pokemonId,
          versionGroupId: versionGroupId,
          learnMethodId: method.id,
        )
        .map(
          (rows) => [
            for (final row in rows)
              PokemonMove(moveId: row.moveId, name: row.name, level: row.level),
          ],
        );
  }
}
