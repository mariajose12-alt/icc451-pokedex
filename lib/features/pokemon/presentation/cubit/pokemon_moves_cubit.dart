import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/features/pokemon/domain/entities/move_learn_method.dart';
import 'package:pokedex/features/pokemon/domain/entities/move_version_group.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_move.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_moves_repository.dart';
import 'package:pokedex/features/pokemon/domain/usecases/sort_pokemon_moves.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_moves_state.dart';

/// Pestaña Movs. (RF-DET-05). Observa las versiones disponibles y, de la
/// versión y el método elegidos, la lista de movimientos. Solo lee de la
/// base local.
class PokemonMovesCubit extends Cubit<PokemonMovesState> {
  PokemonMovesCubit({required this._repository, required int pokemonId})
    : _pokemonId = pokemonId,
      super(const PokemonMovesState()) {
    _groupsSubscription = _repository
        .watchVersionGroups(pokemonId)
        .listen(_onGroups);
  }

  final PokemonMovesRepository _repository;
  final int _pokemonId;

  late final StreamSubscription<List<MoveVersionGroup>> _groupsSubscription;
  StreamSubscription<List<PokemonMove>>? _movesSubscription;

  // Los movimientos sin ordenar: así cambiar el orden no consulta la base.
  List<PokemonMove> _rawMoves = const <PokemonMove>[];

  void _onGroups(List<MoveVersionGroup> groups) {
    if (isClosed) {
      return;
    }

    // Se conserva la versión elegida si sigue existiendo; si no, la más
    // nueva (la primera de la lista).
    final previous = state.versionGroupId;
    final stillThere = groups.any((group) => group.id == previous);
    final int? chosen = stillThere
        ? previous
        : (groups.isEmpty ? null : groups.first.id);

    emit(
      state.copyWith(
        versionGroups: groups,
        versionGroupId: chosen,
        clearVersionGroup: chosen == null,
      ),
    );

    if (chosen != previous) {
      _watchMoves();
    }
  }

  void _watchMoves() {
    _movesSubscription?.cancel();
    _rawMoves = const <PokemonMove>[];

    // Mientras llega la lista nueva no se muestra la anterior.
    emit(state.copyWith(moves: const <PokemonMove>[], movesLoaded: false));

    final versionGroupId = state.versionGroupId;
    if (versionGroupId == null) {
      return;
    }

    _movesSubscription = _repository
        .watchMoves(
          pokemonId: _pokemonId,
          versionGroupId: versionGroupId,
          method: state.method,
        )
        .listen((moves) {
          if (isClosed) {
            return;
          }
          _rawMoves = moves;
          emit(
            state.copyWith(
              moves: sortPokemonMoves(moves, state.order),
              movesLoaded: true,
            ),
          );
        });
  }

  void selectVersionGroup(int id) {
    if (id == state.versionGroupId) {
      return;
    }
    emit(state.copyWith(versionGroupId: id));
    _watchMoves();
  }

  void selectMethod(MoveLearnMethod method) {
    if (method == state.method) {
      return;
    }
    emit(state.copyWith(method: method));
    _watchMoves();
  }

  void selectOrder(MovesOrder order) {
    if (order == state.order) {
      return;
    }
    emit(
      state.copyWith(order: order, moves: sortPokemonMoves(_rawMoves, order)),
    );
  }

  @override
  Future<void> close() async {
    await _groupsSubscription.cancel();
    await _movesSubscription?.cancel();
    return super.close();
  }
}
