import 'package:equatable/equatable.dart';

/// Una especie de una cadena evolutiva, con la condición para evolucionar
/// hasta ella desde la anterior (RF-DET-04).
class EvolutionStage extends Equatable {
  const EvolutionStage({
    required this.speciesId,
    required this.name,
    required this.fromSpeciesId,
    required this.trigger,
    required this.minLevel,
    required this.minHappiness,
    required this.timeOfDay,
    required this.itemName,
  });

  final int speciesId;
  final String name;

  /// Null en la primera especie de la cadena.
  final int? fromSpeciesId;

  /// 'level-up', 'trade', 'use-item'... Null en la primera especie.
  final String? trigger;
  final int? minLevel;
  final int? minHappiness;
  final String? timeOfDay;
  final String? itemName;

  @override
  List<Object?> get props => [
    speciesId,
    name,
    fromSpeciesId,
    trigger,
    minLevel,
    minHappiness,
    timeOfDay,
    itemName,
  ];
}
