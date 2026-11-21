import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/domain/entities/move_learn_method.dart';
import 'package:pokedex/features/pokemon/domain/entities/move_version_group.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_move.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_moves_cubit.dart';

import '../../../helpers/fake_pokemon_moves_repository.dart';

const _newest = MoveVersionGroup(id: 25, name: 'scarlet-violet');
const _oldest = MoveVersionGroup(id: 1, name: 'red-blue');

const _moves = [
  PokemonMove(moveId: 2, name: 'vine-whip', level: 3),
  PokemonMove(moveId: 1, name: 'tackle', level: 1),
];

void main() {
  late FakePokemonMovesRepository repository;
  late PokemonMovesCubit cubit;

  setUp(() {
    repository = FakePokemonMovesRepository();
    cubit = PokemonMovesCubit(repository: repository, pokemonId: 1);
  });

  tearDown(() async {
    await cubit.close();
    await repository.dispose();
  });

  Future<void> loadGroups() async {
    repository.groupsController.add(const [_newest, _oldest]);
    await pumpEventQueue();
  }

  test('sin versiones no hay selección ni consulta de movimientos', () async {
    repository.groupsController.add(const []);
    await pumpEventQueue();

    expect(cubit.state.versionGroupId, isNull);
    expect(repository.requests, isEmpty);
  });

  test('elige la versión más nueva y el método Nivel', () async {
    await loadGroups();

    expect(cubit.state.versionGroupId, 25);
    expect(cubit.state.method, MoveLearnMethod.levelUp);
    expect(repository.requests.last, (25, MoveLearnMethod.levelUp));
  });

  test('carga los movimientos ordenados por nivel', () async {
    await loadGroups();

    repository.movesController.add(_moves);
    await pumpEventQueue();

    expect(
      [for (final m in cubit.state.moves) m.name],
      ['tackle', 'vine-whip'],
    );
    expect(cubit.state.movesLoaded, isTrue);
  });

  test('cambiar de método vuelve a consultar y limpia la lista', () async {
    await loadGroups();
    repository.movesController.add(_moves);
    await pumpEventQueue();

    cubit.selectMethod(MoveLearnMethod.machine);

    expect(repository.requests.last, (25, MoveLearnMethod.machine));
    expect(cubit.state.moves, isEmpty);
    expect(cubit.state.movesLoaded, isFalse);
  });

  test('cambiar de versión consulta la versión elegida', () async {
    await loadGroups();

    cubit.selectVersionGroup(1);

    expect(cubit.state.versionGroupId, 1);
    expect(repository.requests.last, (1, MoveLearnMethod.levelUp));
  });

  test('cambiar el orden reordena sin consultar otra vez', () async {
    await loadGroups();
    repository.movesController.add(_moves);
    await pumpEventQueue();
    final requestsBefore = repository.requests.length;

    cubit.selectOrder(MovesOrder.name);

    expect(
      [for (final m in cubit.state.moves) m.name],
      ['tackle', 'vine-whip'],
    );
    expect(repository.requests.length, requestsBefore);
    expect(cubit.state.order, MovesOrder.name);
  });

  test('si la versión elegida desaparece, pasa a la más nueva', () async {
    await loadGroups();
    cubit.selectVersionGroup(1);

    repository.groupsController.add(const [_newest]);
    await pumpEventQueue();

    expect(cubit.state.versionGroupId, 25);
  });

  test('si la versión elegida sigue existiendo, se conserva', () async {
    await loadGroups();
    cubit.selectVersionGroup(1);

    repository.groupsController.add(const [_newest, _oldest]);
    await pumpEventQueue();

    expect(cubit.state.versionGroupId, 1);
  });
}
