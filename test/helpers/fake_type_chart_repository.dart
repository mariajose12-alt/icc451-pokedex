import 'dart:async';

import 'package:pokedex/features/pokemon/domain/entities/type_chart.dart';
import 'package:pokedex/features/pokemon/domain/repositories/type_chart_repository.dart';

/// Repositorio falso: la prueba decide cuándo llega la tabla y los nombres.
class FakeTypeChartRepository implements TypeChartRepository {
  final StreamController<TypeChart> chartController =
      StreamController<TypeChart>.broadcast();
  final StreamController<Map<int, String>> namesController =
      StreamController<Map<int, String>>.broadcast();

  @override
  Stream<TypeChart> watchTypeChart() => chartController.stream;

  @override
  Stream<Map<int, String>> watchTypeNames() => namesController.stream;

  Future<void> dispose() async {
    await chartController.close();
    await namesController.close();
  }
}
