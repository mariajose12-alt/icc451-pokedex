import 'package:pokedex/features/pokemon/domain/entities/move_learn_method.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_move.dart';

/// Ordena los movimientos por nivel (y nombre si empatan) o solo por nombre.
/// Devuelve una lista nueva: no modifica la que recibe.
List<PokemonMove> sortPokemonMoves(List<PokemonMove> moves, MovesOrder order) {
  final sorted = List<PokemonMove>.of(moves);
  sorted.sort((a, b) {
    if (order == MovesOrder.level) {
      final byLevel = a.level.compareTo(b.level);
      if (byLevel != 0) {
        return byLevel;
      }
    }
    return a.name.compareTo(b.name);
  });
  return sorted;
}
