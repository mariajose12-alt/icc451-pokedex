import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pokedex/core/connectivity/connectivity_monitor.dart';
import 'package:pokedex/core/connectivity/service_availability.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_repository.dart';

/// Decide CUÁNDO se actualiza el catálogo por su cuenta (OF-20, PS-04).
/// No descarga nada: solo le pide al repositorio que actualice.
///  - Al reconectar (Offline o Servicio no disponible -> Online): sync forzada.
///  - Cada [periodicInterval] mientras el servicio está Online: sync solo
///    si los datos están viejos (PS-03).
class CatalogSyncScheduler {
  CatalogSyncScheduler({
    required this._monitor,
    required this._repository,
    this.periodicInterval = const Duration(minutes: 15),
    this.minGapBetweenReconnections = const Duration(minutes: 2),
    this._clock = DateTime.now,
  });

  final ConnectivityMonitor _monitor;
  final PokemonRepository _repository;
  final Duration periodicInterval;
  final Duration minGapBetweenReconnections;
  final DateTime Function() _clock;

  StreamSubscription<ServiceAvailability>? _subscription;
  Timer? _timer;

  // Estado anterior, para saber si hubo una CAÍDA antes de volver a Online.
  late ServiceAvailability _previous;

  // Cuándo se hizo la última sync forzada por reconexión.
  DateTime? _lastReconnectionSync;

  /// Empieza a escuchar. Se llama una sola vez, al arrancar la app.
  void start() {
    _previous = _monitor.current;
    _subscription = _monitor.watch().listen(_onAvailability);
    _timer = Timer.periodic(periodicInterval, (_) => _onTick());
  }

  void _onAvailability(ServiceAvailability received) {
    // ¿Veníamos de una caída? "Verificando" NO cuenta como caída.
    final wasDown =
        _previous == ServiceAvailability.offline ||
        _previous == ServiceAvailability.serviceUnavailable;
    _previous = received;

    // Solo interesa el paso de caída a Online.
    if (received != ServiceAvailability.online || !wasDown) {
      return;
    }

    // Si ya se hizo una hace poco, se ignora (protege la cuota de la API).
    final last = _lastReconnectionSync;
    if (last != null &&
        _clock().difference(last) < minGapBetweenReconnections) {
      return;
    }
    _lastReconnectionSync = _clock();

    unawaited(_refresh(onlyIfStale: false, reason: 'reconexión'));
  }

  void _onTick() {
    // Sin servicio no tiene sentido intentarlo.
    if (_monitor.current != ServiceAvailability.online) {
      return;
    }
    unawaited(_refresh(onlyIfStale: true, reason: 'periódica'));
  }

  Future<void> _refresh({
    required bool onlyIfStale,
    required String reason,
  }) async {
    try {
      await _repository.refreshCatalog(onlyIfStale: onlyIfStale);
      debugPrint('Scheduler: sync $reason terminada');
    } catch (error) {
      // Un fallo aquí no debe romper la app: los datos locales siguen
      // intactos (OF-04) y el coordinador ya dejó el estado en "failed".
      debugPrint('Scheduler: sync $reason falló -> $error');
    }
  }

  Future<void> dispose() async {
    _timer?.cancel();
    await _subscription?.cancel();
  }
}
