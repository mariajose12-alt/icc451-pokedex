import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/connectivity/service_availability.dart';
import 'package:pokedex/features/pokemon/data/sync/catalog_sync_scheduler.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_repository.dart';

import '../../../helpers/fake_connectivity_monitor.dart';

/// Repositorio falso: solo anota con qué valor de onlyIfStale lo llamaron.
class _RecordingRepository implements PokemonRepository {
  final List<bool> calls = [];

  @override
  Stream<List<Pokemon>> watchCatalog() => const Stream.empty();

  @override
  Future<void> refreshCatalog({bool onlyIfStale = false}) async {
    calls.add(onlyIfStale);
  }
}

// Deja correr los eventos pendientes de los streams.
Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  late FakeConnectivityMonitor monitor;
  late _RecordingRepository repository;
  late CatalogSyncScheduler scheduler;

  setUp(() {
    repository = _RecordingRepository();
  });

  tearDown(() async {
    await scheduler.dispose();
    await monitor.dispose();
  });

  test('al reconectar (Offline -> Online) pide una sync forzada', () async {
    monitor = FakeConnectivityMonitor(ServiceAvailability.offline);
    scheduler = CatalogSyncScheduler(monitor: monitor, repository: repository)
      ..start();
    await _settle();

    monitor.emit(ServiceAvailability.online);
    await _settle();

    expect(repository.calls, [false]); // false = forzada, no solo si vieja
  });

  test(
    'el primer Online (Verificando -> Online) no cuenta como reconexión',
    () async {
      monitor = FakeConnectivityMonitor(ServiceAvailability.checking);
      scheduler = CatalogSyncScheduler(monitor: monitor, repository: repository)
        ..start();
      await _settle();

      monitor.emit(ServiceAvailability.online);
      await _settle();

      expect(repository.calls, isEmpty);
    },
  );

  test('dos reconexiones seguidas generan una sola sync', () async {
    monitor = FakeConnectivityMonitor(ServiceAvailability.offline);
    scheduler = CatalogSyncScheduler(monitor: monitor, repository: repository)
      ..start();
    await _settle();

    monitor.emit(ServiceAvailability.online);
    await _settle();
    monitor.emit(ServiceAvailability.offline);
    await _settle();
    monitor.emit(ServiceAvailability.online);
    await _settle();

    expect(repository.calls.length, 1);
  });

  test(
    'con el servicio Online, el temporizador pide sync solo si está vieja',
    () async {
      // Empieza Online: no hay reconexión, solo cuentan los ticks.
      monitor = FakeConnectivityMonitor(ServiceAvailability.online);
      scheduler = CatalogSyncScheduler(
        monitor: monitor,
        repository: repository,
        periodicInterval: const Duration(milliseconds: 30),
      )..start();

      await Future<void>.delayed(const Duration(milliseconds: 150));

      expect(repository.calls, isNotEmpty);
      // true = "solo si está vieja" (PS-03).
      expect(repository.calls.every((onlyIfStale) => onlyIfStale), isTrue);
    },
  );

  test('con el servicio Offline, el temporizador no pide nada', () async {
    monitor = FakeConnectivityMonitor(ServiceAvailability.offline);
    scheduler = CatalogSyncScheduler(
      monitor: monitor,
      repository: repository,
      periodicInterval: const Duration(milliseconds: 30),
    )..start();

    await Future<void>.delayed(const Duration(milliseconds: 150));

    expect(repository.calls, isEmpty);
  });
}
