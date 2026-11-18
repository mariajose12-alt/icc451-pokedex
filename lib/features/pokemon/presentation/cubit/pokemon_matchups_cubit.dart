import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/features/pokemon/domain/entities/type_chart.dart';
import 'package:pokedex/features/pokemon/domain/repositories/type_chart_repository.dart';
import 'package:pokedex/features/pokemon/domain/usecases/calculate_matchups.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_matchups_state.dart';

/// Calcula los matchups de un Pokémon (RF-DET-06).
///
/// Cómo funciona:
///  1. Escucha dos flujos de la base: la tabla de efectividades y los
///     nombres de los tipos.
///  2. Cada vez que cualquiera cambia, recalcula con [calculateMatchups]
///     y emite el estado nuevo.
/// Si la tabla llega después de abrir el detalle (primera sincronización),
/// la sección se completa sola.
class PokemonMatchupsCubit extends Cubit<PokemonMatchupsState> {
  PokemonMatchupsCubit({
    required TypeChartRepository repository,
    required this._defenderTypeIds,
  }) : super(PokemonMatchupsState.empty) {
    _chartSubscription = repository.watchTypeChart().listen((chart) {
      _chart = chart;
      _recalculate();
    });
    _namesSubscription = repository.watchTypeNames().listen((names) {
      _typeNames = names;
      _recalculate();
    });
  }

  final List<int> _defenderTypeIds;

  // Últimos valores recibidos de cada flujo.
  TypeChart _chart = TypeChart(const []);
  Map<int, String> _typeNames = const <int, String>{};

  late final StreamSubscription<TypeChart> _chartSubscription;
  late final StreamSubscription<Map<int, String>> _namesSubscription;

  void _recalculate() {
    emit(
      PokemonMatchupsState(
        matchups: calculateMatchups(
          defenderTypeIds: _defenderTypeIds,
          chart: _chart,
        ),
        typeNames: _typeNames,
      ),
    );
  }

  // Al cerrar, se cancelan las dos suscripciones para no dejar escuchas vivas.
  @override
  Future<void> close() async {
    await _chartSubscription.cancel();
    await _namesSubscription.cancel();
    return super.close();
  }
}
