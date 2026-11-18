import 'package:pokedex/features/pokemon/domain/entities/damage_matchups.dart';
import 'package:pokedex/features/pokemon/domain/entities/type_chart.dart';

/// Calcula debilidades, resistencias e inmunidades de un Pokémon (RF-DET-06).
///
/// Cómo funciona:
///  1. Para cada tipo atacante de la tabla, se parte de 100 %.
///  2. Se multiplica por el factor contra cada tipo del Pokémon:
///     acumulado = acumulado × factor / 100.
///  3. Según el resultado: 0 es inmunidad, más de 100 es debilidad y menos
///     de 100 es resistencia. El 100 (neutral) no se lista.
/// Todo es con enteros; con los factores 0, 50, 100 y 200 la división entre
/// 100 siempre es exacta.
DamageMatchups calculateMatchups({
  required List<int> defenderTypeIds,
  required TypeChart chart,
}) {
  // Sin tipos o sin tabla no hay nada que calcular.
  if (defenderTypeIds.isEmpty || chart.isEmpty) {
    return DamageMatchups.empty;
  }

  final weaknesses = <TypeMatchup>[];
  final resistances = <TypeMatchup>[];
  final immunities = <TypeMatchup>[];

  for (final attackerId in chart.attackerTypeIds) {
    var percent = TypeChart.neutralPercent;
    for (final defenderId in defenderTypeIds) {
      // Un factor 0 deja el acumulado en 0 y ya no cambia (inmunidad).
      percent = percent * chart.factor(attackerId, defenderId) ~/ 100;
    }

    final matchup = TypeMatchup(typeId: attackerId, multiplierPercent: percent);
    if (percent == 0) {
      immunities.add(matchup);
    } else if (percent > TypeChart.neutralPercent) {
      weaknesses.add(matchup);
    } else if (percent < TypeChart.neutralPercent) {
      resistances.add(matchup);
    }
  }

  // Orden estable: las debilidades de mayor a menor multiplicador, las
  // resistencias de menor a mayor (las más fuertes primero) y, a igualdad,
  // por id de tipo.
  weaknesses.sort(_byPercentDescending);
  resistances.sort(_byPercentAscending);

  return DamageMatchups(
    weaknesses: weaknesses,
    resistances: resistances,
    immunities: immunities,
  );
}

int _byPercentDescending(TypeMatchup a, TypeMatchup b) {
  final byPercent = b.multiplierPercent.compareTo(a.multiplierPercent);
  return byPercent != 0 ? byPercent : a.typeId.compareTo(b.typeId);
}

int _byPercentAscending(TypeMatchup a, TypeMatchup b) {
  final byPercent = a.multiplierPercent.compareTo(b.multiplierPercent);
  return byPercent != 0 ? byPercent : a.typeId.compareTo(b.typeId);
}