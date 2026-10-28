import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:pokedex/core/async/current_then_changes.dart';
import 'package:pokedex/core/network/network_exceptions.dart';
import 'package:pokedex/core/network/poke_api_client.dart';

import 'connectivity_monitor.dart';
import 'service_availability.dart';

class ApiConnectivityMonitor implements ConnectivityMonitor {
  ApiConnectivityMonitor({required this._connectivity, required this._client});

  final Connectivity _connectivity;
  final PokeApiClient _client;

  // Consulta mínima: un solo Pokémon y solo su id.
  static const String _healthQuery = 'query { pokemon(limit: 1) { id } }';

  // Con el servicio Online se vuelve a verificar cada 5 min (12 llamadas/h).
  static const Duration _onlineRecheck = Duration(minutes: 5);

  // Con el servicio caído se espacia: 30 s, 1, 2 y 5 min (tope).
  // Reintentar cada 30 s gastaría la cuota de 100 llamadas por hora.
  static const List<Duration> _retryDelays = <Duration>[
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 2),
    Duration(minutes: 5),
  ];

  final StreamController<ServiceAvailability> _controller =
      StreamController<ServiceAvailability>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _networkSubscription;
  Timer? _timer;

  ServiceAvailability _current = ServiceAvailability.checking;
  bool _isChecking = false;
  bool _isDisposed = false;
  int _consecutiveFailures = 0;

  @override
  ServiceAvailability get current => _current;

  @override
  Stream<ServiceAvailability> watch() {
    // Primero el estado actual, para que quien se suscriba no espere.
    return currentThenChanges(
      current: () => _current,
      changes: _controller.stream,
    );
  }

  @override
  Future<void> start() async {
    // 1. Cada cambio de red dispara una comprobación real (OF-11, IND-03).
    _networkSubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      debugPrint('Monitor: la red cambió a $results');
      unawaited(checkNow());
    });

    // 2. Primera comprobación.
    await checkNow();
  }

  @override
  Future<void> checkNow() async {
    // Evita dos comprobaciones a la vez (como RNF-RES-03, pero para el monitor).
    if (_isChecking || _isDisposed) return;
    _isChecking = true;
    _timer?.cancel();

    // Por defecto, si algo sale mal, nunca se dice Online.
    var result = ServiceAvailability.serviceUnavailable;

    try {
      // Paso 1: hay red?
      final networks = await _connectivity.checkConnectivity();

      if (networks.contains(ConnectivityResult.none)) {
        result = ServiceAvailability.offline;
      } else {
        // Paso 2: hay red; responde la API de verdad?
        try {
          await _client.query(_healthQuery);
          result = ServiceAvailability.online;
        } on PokeApiException catch (error) {
          // Timeout, sin conexión al servidor, 5xx, error GraphQL...
          debugPrint('Monitor: la API no respondió bien -> $error');
        }
      }
    } catch (error) {
      debugPrint('Monitor: error inesperado -> $error');
    } finally {
      _isChecking = false;
    }

    if (_isDisposed) return;

    // Paso 3: emitir solo si el estado cambió (evita parpadeos, IND-06).
    if (result != _current) {
      _current = result;
      _controller.add(result);
      debugPrint('Monitor: estado -> $result');
    }

    // Paso 4: programar la siguiente comprobación.
    if (result == ServiceAvailability.serviceUnavailable) {
      final lastIndex = _retryDelays.length - 1;
      final index = _consecutiveFailures < lastIndex
          ? _consecutiveFailures
          : lastIndex;
      final delay = _retryDelays[index];
      _consecutiveFailures++;
      debugPrint('Monitor: reintento en ${delay.inSeconds} s');
      _timer = Timer(delay, () => unawaited(checkNow()));
    } else if (result == ServiceAvailability.online) {
      _consecutiveFailures = 0;
      _timer = Timer(_onlineRecheck, () => unawaited(checkNow()));
    } else {
      // Offline: sin temporizador, se espera el evento de red.
      _consecutiveFailures = 0;
    }
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
    _timer?.cancel();
    await _networkSubscription?.cancel();
    await _controller.close();
  }
}
