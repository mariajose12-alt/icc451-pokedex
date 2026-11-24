import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/domain/entities/evolution_node.dart';
import 'package:pokedex/features/pokemon/domain/entities/evolution_stage.dart';

EvolutionStage _stage(int id, String name, {int? from}) => EvolutionStage(
  speciesId: id,
  name: name,
  fromSpeciesId: from,
  trigger: from == null ? null : 'level-up',
  minLevel: null,
  minHappiness: null,
  timeOfDay: null,
  itemName: null,
);

void main() {
  test('lista vacía no genera árbol', () {
    expect(EvolutionNode.fromStages(const []), isNull);
  });

  test('sin especie inicial no genera árbol', () {
    final stages = [_stage(2, 'ivysaur', from: 1)];
    expect(EvolutionNode.fromStages(stages), isNull);
  });

  test('cadena lineal: Bulbasaur → Ivysaur → Venusaur', () {
    final tree = EvolutionNode.fromStages([
      _stage(3, 'venusaur', from: 2),
      _stage(1, 'bulbasaur'),
      _stage(2, 'ivysaur', from: 1),
    ])!;

    expect(tree.stage.name, 'bulbasaur');
    expect(tree.children.length, 1);
    expect(tree.children.first.stage.name, 'ivysaur');
    expect(tree.children.first.children.first.stage.name, 'venusaur');
  });

  test('con ramas: Eevee tiene varios hijos ordenados por id', () {
    final tree = EvolutionNode.fromStages([
      _stage(133, 'eevee'),
      _stage(136, 'flareon', from: 133),
      _stage(134, 'vaporeon', from: 133),
      _stage(135, 'jolteon', from: 133),
    ])!;

    expect(
      [for (final child in tree.children) child.stage.speciesId],
      [134, 135, 136],
    );
  });

  test('una especie sin evoluciones queda como hoja', () {
    final tree = EvolutionNode.fromStages([_stage(132, 'ditto')])!;
    expect(tree.children, isEmpty);
  });

  test('un ciclo en los datos no se cuelga', () {
    final tree = EvolutionNode.fromStages([
      _stage(1, 'a'),
      _stage(2, 'b', from: 1),
      _stage(1, 'a', from: 2),
    ]);
    expect(tree, isNotNull);
  });
}
