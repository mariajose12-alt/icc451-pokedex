import 'package:equatable/equatable.dart';
import 'package:pokedex/features/pokemon/domain/entities/evolution_stage.dart';

/// Un punto del árbol evolutivo: una especie y las especies a las que
/// evoluciona. Eevee tiene varios hijos; Charmander, uno.
class EvolutionNode extends Equatable {
  const EvolutionNode({
    required this.stage,
    this.children = const <EvolutionNode>[],
  });

  final EvolutionStage stage;
  final List<EvolutionNode> children;

  /// Arma el árbol a partir de la lista plana que viene de la base.
  /// Devuelve null si la lista está vacía o si no hay especie inicial.
  static EvolutionNode? fromStages(List<EvolutionStage> stages) {
    // La especie inicial es la que no viene de ninguna otra.
    EvolutionStage? root;
    for (final stage in stages) {
      if (stage.fromSpeciesId == null) {
        root = stage;
        break;
      }
    }
    if (root == null) {
      return null;
    }

    // Especies ya colocadas: evita ciclos y duplicados si los datos vinieran mal.
    final placed = <int>{};

    EvolutionNode build(EvolutionStage stage) {
      placed.add(stage.speciesId);

      final next = [
        for (final candidate in stages)
          if (candidate.fromSpeciesId == stage.speciesId) candidate,
      ]..sort((a, b) => a.speciesId.compareTo(b.speciesId));

      final children = <EvolutionNode>[];
      for (final child in next) {
        if (placed.contains(child.speciesId)) {
          continue;
        }
        children.add(build(child));
      }
      return EvolutionNode(stage: stage, children: children);
    }

    return build(root);
  }

  @override
  List<Object?> get props => [stage, children];
}
