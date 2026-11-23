import 'package:equatable/equatable.dart';
import 'package:pokedex/features/pokemon/domain/entities/move_learn_method.dart';
import 'package:pokedex/features/pokemon/domain/entities/move_version_group.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_move.dart';

/// Lo que muestra la pestaña Movs.: versiones disponibles, lo elegido y los
/// movimientos ya ordenados.
class PokemonMovesState extends Equatable {
  const PokemonMovesState({
    this.versionGroups = const <MoveVersionGroup>[],
    this.versionGroupId,
    this.method = MoveLearnMethod.levelUp,
    this.order = MovesOrder.level,
    this.moves = const <PokemonMove>[],
    this.movesLoaded = false,
  });

  /// Versiones con movimientos para este Pokémon. Vacía = aún no se
  /// descargaron.
  final List<MoveVersionGroup> versionGroups;
  final int? versionGroupId;
  final MoveLearnMethod method;
  final MovesOrder order;
  final List<PokemonMove> moves;

  /// ¿Ya llegó la lista de la versión y el método elegidos? Distingue
  /// «cargando» de «no hay movimientos».
  final bool movesLoaded;

  /// La versión elegida, o null si no hay.
  MoveVersionGroup? get selectedVersionGroup {
    for (final group in versionGroups) {
      if (group.id == versionGroupId) {
        return group;
      }
    }
    return null;
  }

  PokemonMovesState copyWith({
    List<MoveVersionGroup>? versionGroups,
    int? versionGroupId,
    bool clearVersionGroup = false,
    MoveLearnMethod? method,
    MovesOrder? order,
    List<PokemonMove>? moves,
    bool? movesLoaded,
  }) {
    return PokemonMovesState(
      versionGroups: versionGroups ?? this.versionGroups,
      versionGroupId: clearVersionGroup
          ? null
          : (versionGroupId ?? this.versionGroupId),
      method: method ?? this.method,
      order: order ?? this.order,
      moves: moves ?? this.moves,
      movesLoaded: movesLoaded ?? this.movesLoaded,
    );
  }

  @override
  List<Object?> get props => [
    versionGroups,
    versionGroupId,
    method,
    order,
    moves,
    movesLoaded,
  ];
}
