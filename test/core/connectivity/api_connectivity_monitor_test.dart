import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/connectivity/api_connectivity_monitor.dart';
import 'package:pokedex/core/connectivity/service_availability.dart';
import 'package:pokedex/core/network/network_exceptions.dart';
import 'package:pokedex/core/network/poke_api_client.dart';

// Red falsa: se controla a mano.
class FakeConnectivity implements Connectivity {
  FakeConnectivity(this._results);

  List<ConnectivityResult> _results;
  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  void emit(List<ConnectivityResult> results) {
    _results = results;
    _controller.add(results);
  }

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => _results;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;
}

// Cliente falso: cuenta llamadas y puede fallar a voluntad.
class FakeApiClient implements PokeApiClient {
  int calls = 0;
  PokeApiException? error;

  @override
  final String url = 'fake';

  @override
  final Duration timeout = const Duration(seconds: 1);

  @override
  Future<Map<String, dynamic>> query(
    String document, {
    Map<String, dynamic> variables = const <String, dynamic>{},
  }) async {
    calls++;
    if (error != null) throw error!;
    return <String, dynamic>{'pokemon': <dynamic>[]};
  }
}

void main() {
  late FakeConnectivity network;
  late FakeApiClient api;
  late ApiConnectivityMonitor monitor;

  void build(List<ConnectivityResult> initial) {
    network = FakeConnectivity(initial);
    api = FakeApiClient();
    monitor = ApiConnectivityMonitor(connectivity: network, client: api);
  }

  tearDown(() async {
    await monitor.dispose();
  });

  test('sin red: Offline y no llama a la API', () async {
    build(<ConnectivityResult>[ConnectivityResult.none]);
    await monitor.start();

    expect(monitor.current, ServiceAvailability.offline);
    expect(api.calls, 0);
  });

  test('con red y API que responde: Online', () async {
    build(<ConnectivityResult>[ConnectivityResult.wifi]);
    await monitor.start();

    expect(monitor.current, ServiceAvailability.online);
    expect(api.calls, 1);
  });

  test(
    'con red y API caída: Servicio no disponible, nunca Online (PA-08)',
    () async {
      build(<ConnectivityResult>[ConnectivityResult.wifi]);
      api.error = const ServerErrorException(500);
      await monitor.start();

      expect(monitor.current, ServiceAvailability.serviceUnavailable);
    },
  );

  test(
    'al volver la red pasa de Offline a Online sin intervención (PA-07)',
    () async {
      build(<ConnectivityResult>[ConnectivityResult.none]);
      await monitor.start();
      expect(monitor.current, ServiceAvailability.offline);

      final future = expectLater(
        monitor.watch(),
        emitsThrough(ServiceAvailability.online),
      );
      network.emit(<ConnectivityResult>[ConnectivityResult.wifi]);
      await future;
    },
  );
}
