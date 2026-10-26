import 'dart:async';

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
  Stream<ServiceAvailability> watch() async* {
    yield _current;
    yield* _controller.stream;
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
    await _controller.close();
  }
}
