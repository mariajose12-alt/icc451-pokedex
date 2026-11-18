import 'package:equatable/equatable.dart';

import 'type_efficacy.dart';

/// Tabla completa de efectividades entre tipos, indexada para consultarla
/// rápido: atacante → defensor → porcentaje.
class TypeChart extends Equatable {
  TypeChart(Iterable<TypeEfficacy> entries) : _factors = _index(entries);

  /// Daño normal. Es el valor que se asume si un par no aparece en la tabla.
  static const int neutralPercent = 100;

  final Map<int, Map<int, int>> _factors;

  static Map<int, Map<int, int>> _index(Iterable<TypeEfficacy> entries) {
    final result = <int, Map<int, int>>{};
    for (final entry in entries) {
      // putIfAbsent crea el mapa interno la primera vez que aparece el atacante.
      result.putIfAbsent(entry.damageTypeId, () => <int, int>{})[entry
          .targetTypeId] =
          entry.damageFactor;
    }
    return result;
  }

  /// true si todavía no hay datos (la tabla aún no se ha descargado).
  bool get isEmpty => _factors.isEmpty;

  /// Ids de todos los tipos que atacan, de menor a mayor.
  List<int> get attackerTypeIds => _factors.keys.toList()..sort();

  /// Porcentaje de daño de [attackerTypeId] contra [defenderTypeId].
  int factor(int attackerTypeId, int defenderTypeId) {
    return _factors[attackerTypeId]?[defenderTypeId] ?? neutralPercent;
  }

  @override
  List<Object?> get props => [_factors];
}