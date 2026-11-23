import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/domain/entities/damage_matchups.dart';
import 'package:pokedex/features/pokemon/domain/entities/type_chart.dart';
import 'package:pokedex/features/pokemon/domain/entities/type_efficacy.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_matchups_cubit.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_matchups_state.dart';

import '../../../helpers/fake_type_chart_repository.dart';

TypeEfficacy _e(int attacker, int defender, int factor) => TypeEfficacy(
  damageTypeId: attacker,
  targetTypeId: defender,
  damageFactor: factor,
);

// Agua pega ×2 a Fuego y Planta pega ×0.5. Defensor: Fuego (id 10).
final TypeChart _chart = TypeChart([_e(11, 10, 200), _e(12, 10, 50)]);
const Map<int, String> _names = {10: 'fire', 11: 'water', 12: 'grass'};

void main() {
  late FakeTypeChartRepository repository;
  late PokemonMatchupsCubit cubit;

  setUp(() {
    repository = FakeTypeChartRepository();
    cubit = PokemonMatchupsCubit(repository: repository, defenderTypeIds: [10]);
  });

  tearDown(() async {
    await cubit.close();
    await repository.dispose();
  });

  test('empieza vacío, antes de que llegue la tabla', () {
    expect(cubit.state, PokemonMatchupsState.empty);
  });

  test('con la tabla y los nombres calcula los matchups', () async {
    repository.chartController.add(_chart);
    repository.namesController.add(_names);
    await pumpEventQueue();

    expect(cubit.state.matchups.weaknesses, const [
      TypeMatchup(typeId: 11, multiplierPercent: 200),
    ]);
    expect(cubit.state.matchups.resistances, const [
      TypeMatchup(typeId: 12, multiplierPercent: 50),
    ]);
    expect(cubit.state.typeNames[11], 'water');
  });

  test(
    'si la tabla llega antes que los nombres, los nombres se añaden después',
    () async {
      repository.chartController.add(_chart);
      await pumpEventQueue();

      expect(cubit.state.matchups.isEmpty, isFalse);
      expect(cubit.state.typeNames, isEmpty);

      repository.namesController.add(_names);
      await pumpEventQueue();

      expect(cubit.state.typeNames[11], 'water');
    },
  );

  test('al cerrar, cancela las suscripciones', () async {
    expect(repository.chartController.hasListener, isTrue);

    await cubit.close();

    expect(repository.chartController.hasListener, isFalse);
    expect(repository.namesController.hasListener, isFalse);
  });
}
