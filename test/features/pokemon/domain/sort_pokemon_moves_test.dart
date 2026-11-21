import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/domain/entities/move_learn_method.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_move.dart';
import 'package:pokedex/features/pokemon/domain/usecases/sort_pokemon_moves.dart';

PokemonMove _move(int id, String name, int level) =>
    PokemonMove(moveId: id, name: name, level: level);

void main() {
  final moves = [
    _move(3, 'vine-whip', 7),
    _move(1, 'tackle', 1),
    _move(2, 'growl', 1),
    _move(4, 'razor-leaf', 20),
  ];

  test('por nivel: primero el nivel y, si empatan, el nombre', () {
    final sorted = sortPokemonMoves(moves, MovesOrder.level);

    expect(
      [for (final m in sorted) m.name],
      ['growl', 'tackle', 'vine-whip', 'razor-leaf'],
    );
  });

  test('por nombre: alfabético, sin mirar el nivel', () {
    final sorted = sortPokemonMoves(moves, MovesOrder.name);

    expect(
      [for (final m in sorted) m.name],
      ['growl', 'razor-leaf', 'tackle', 'vine-whip'],
    );
  });

  test('no modifica la lista original', () {
    final original = [...moves];

    sortPokemonMoves(moves, MovesOrder.name);

    expect(moves, original);
  });

  test('una lista vacía devuelve una lista vacía', () {
    expect(sortPokemonMoves(const [], MovesOrder.level), isEmpty);
  });

  test('un movimiento aprendido en dos niveles aparece dos veces', () {
    final sorted = sortPokemonMoves([
      _move(1, 'tackle', 1),
      _move(1, 'tackle', 30),
    ], MovesOrder.level);

    expect([for (final m in sorted) m.level], [1, 30]);
  });
}
