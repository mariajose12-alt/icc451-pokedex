import 'package:pokedex/features/pokemon/domain/entities/type_chart.dart';

/// Acceso a la tabla de efectividades entre tipos.
abstract interface class TypeChartRepository {
  /// Observa la tabla guardada en la base local (OF-16). Emite una tabla
  /// vacía si todavía no se descargó.
  Stream<TypeChart> watchTypeChart();

  /// Nombre de cada tipo (id → "grass"), para poner nombre a los atacantes.
  Stream<Map<int, String>> watchTypeNames();
}