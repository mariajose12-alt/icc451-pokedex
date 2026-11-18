import 'package:pokedex/features/pokemon/data/datasources/local/pokemon_local_datasource.dart';
import 'package:pokedex/features/pokemon/domain/entities/type_chart.dart';
import 'package:pokedex/features/pokemon/domain/repositories/type_chart_repository.dart';

/// Lee la tabla de efectividades SOLO desde la base local (Offline-First).
/// La descarga la hace el sincronizador (CatalogSyncCoordinator).
class OfflineFirstTypeChartRepository implements TypeChartRepository {
  OfflineFirstTypeChartRepository({required this._local});

  final PokemonLocalDataSource _local;

  @override
  Stream<TypeChart> watchTypeChart() => _local.watchTypeChart();

  @override
  Stream<Map<int, String>> watchTypeNames() => _local.watchTypeNames();
}