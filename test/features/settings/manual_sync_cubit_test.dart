import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/errors/failures.dart';
import 'package:pokedex/features/pokemon/data/repositories/fake_pokemon_repository.dart';
import 'package:pokedex/features/settings/presentation/cubit/manual_sync_cubit.dart';

/// Cuenta cuántas veces se pidió la descarga.
class _CountingRepository extends FakePokemonRepository {
  _CountingRepository()
    : super(scenario: FakeScenario.success, delay: Duration.zero);

  int calls = 0;

  @override
  Future<void> refreshCatalog({bool onlyIfStale = false}) async {
    calls++;
    await super.refreshCatalog(onlyIfStale: onlyIfStale);
  }
}

void main() {
  test('sincroniza y vuelve a reposo', () async {
    final cubit = ManualSyncCubit(
      repository: FakePokemonRepository(
        scenario: FakeScenario.success,
        delay: Duration.zero,
      ),
    );

    await cubit.sync();

    expect(cubit.state, isA<ManualSyncIdle>());
    await cubit.close();
  });

  test('si falla, queda en fallido con el motivo', () async {
    final cubit = ManualSyncCubit(
      repository: FakePokemonRepository(
        scenario: FakeScenario.hasDataButFails,
        delay: Duration.zero,
      ),
    );

    await cubit.sync();

    final state = cubit.state as ManualSyncFailed;
    expect(state.failure, isA<ServiceFailure>());
    await cubit.close();
  });

  test('un segundo toque mientras corre no lanza otra descarga', () async {
    final repository = _CountingRepository();
    final cubit = ManualSyncCubit(repository: repository);

    final first = cubit.sync();
    final second = cubit.sync();
    expect(cubit.state, isA<ManualSyncRunning>());
    await Future.wait([first, second]);

    expect(repository.calls, 1);
    await cubit.close();
  });
}
