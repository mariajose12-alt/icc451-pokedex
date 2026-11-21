import 'package:equatable/equatable.dart';

/// Un tipo atacante y cuánto daño le hace al Pokémon.
class TypeMatchup extends Equatable {
  const TypeMatchup({required this.typeId, required this.multiplierPercent});

  final int typeId;

  /// Multiplicador en porcentaje: 0, 25, 50, 200 o 400 (×0, ×0.25, ×0.5,
  /// ×2 y ×4). Se guarda entero para evitar errores de decimales.
  final int multiplierPercent;

  @override
  List<Object?> get props => [typeId, multiplierPercent];
}

/// Resultado de los matchups de un Pokémon (RF-DET-06).
class DamageMatchups extends Equatable {
  const DamageMatchups({
    required this.weaknesses,
    required this.resistances,
    required this.immunities,
  });

  /// Sin datos: las tres listas vacías.
  static const DamageMatchups empty = DamageMatchups(
    weaknesses: [],
    resistances: [],
    immunities: [],
  );

  /// ×4 primero y luego ×2.
  final List<TypeMatchup> weaknesses;

  /// ×0.25 primero y luego ×0.5.
  final List<TypeMatchup> resistances;

  /// ×0.
  final List<TypeMatchup> immunities;

  bool get isEmpty =>
      weaknesses.isEmpty && resistances.isEmpty && immunities.isEmpty;

  @override
  List<Object?> get props => [weaknesses, resistances, immunities];
}
