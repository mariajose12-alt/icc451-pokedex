import 'dart:async';

import 'package:pokedex/core/async/current_then_changes.dart';
import 'package:pokedex/core/connectivity/connectivity_monitor.dart';
import 'package:pokedex/core/connectivity/service_availability.dart';

/// Monitor falso para pruebas: el estado se controla a mano.
class FakeConnectivityMonitor implements ConnectivityMonitor {
  FakeConnectivityMonitor([
    ServiceAvailability initial = ServiceAvailability.checking,
  ]) : _current = initial;

  final StreamController<ServiceAvailability> _controller =
      StreamController<ServiceAvailability>.broadcast();

  ServiceAvailability _current;

  @override
  ServiceAvailability get current => _current;

  @override
  Stream<ServiceAvailability> watch() {
    return currentThenChanges(
      current: () => _current,
      changes: _controller.stream,
    );
  }

  void emit(ServiceAvailability value) {
    _current = value;
    _controller.add(value);
  }

  @override
  Future<void> start() async {}

  @override
  Future<void> checkNow() async {}

  @override
  Future<void> dispose() async {
    // Sin await a propósito: en testWidgets el futuro de close() puede no
    // completarse hasta que se procesen microtareas, y el test se colgaría.
    unawaited(_controller.close());
  }
}
