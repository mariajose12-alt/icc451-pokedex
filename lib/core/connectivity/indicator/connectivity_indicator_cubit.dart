import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/core/connectivity/connectivity_monitor.dart';
import 'package:pokedex/core/connectivity/service_availability.dart';
import 'package:pokedex/core/sync/sync_info.dart';

import 'connectivity_indicator_state.dart';

/// Junta el monitor (disponibilidad) y la fuente de sincronización,
/// y decide cuándo cambiar lo que ve el usuario.
class ConnectivityIndicatorCubit extends Cubit<ConnectivityIndicatorState> {
  ConnectivityIndicatorCubit({
    required ConnectivityMonitor monitor,
    required SyncInfoSource syncSource,
    this._stabilityWindow = const Duration(milliseconds: 1200),
  }) : super(
         ConnectivityIndicatorState(
           availability: monitor.current,
           isSyncing: syncSource.current.isSyncing,
           lastSyncAt: syncSource.current.lastSyncAt,
         ),
       ) {
    // Se escuchan las dos fuentes por separado.
    _availabilitySubscription = monitor.watch().listen(_onAvailability);
    _syncSubscription = syncSource.watch().listen(_onSync);
  }

  final Duration _stabilityWindow;

  StreamSubscription<ServiceAvailability>? _availabilitySubscription;
  StreamSubscription<SyncInfo>? _syncSubscription;

  // Cambio de disponibilidad que está esperando su ventana.
  Timer? _timer;

  void _onAvailability(ServiceAvailability received) {
    // Siempre manda el valor más reciente: se descarta cualquier espera anterior.
    _timer?.cancel();

    // Caso 1: es lo mismo que ya se muestra.
    // Ej: se cayó la red y volvió en menos de 1.2 s. No hay nada que cambiar.
    if (received == state.availability) return;

    // Caso 2: primera respuesta real. Se muestra sin esperar,
    // porque no hay nada anterior que pueda parpadear.
    if (state.availability == ServiceAvailability.checking) {
      emit(
        ConnectivityIndicatorState(
          availability: received,
          isSyncing: state.isSyncing,
          lastSyncAt: state.lastSyncAt,
        ),
      );
      return;
    }

    // Caso 3: un cambio normal. Se espera la ventana. Si llega otro valor
    // antes, este temporizador se cancela y empieza uno nuevo.
    _timer = Timer(_stabilityWindow, () {
      emit(
        ConnectivityIndicatorState(
          availability: received,
          isSyncing: state.isSyncing,
          lastSyncAt: state.lastSyncAt,
        ),
      );
    });
  }

  void _onSync(SyncInfo info) {
    // La sincronización se muestra de inmediato: el usuario debe ver
    // que la app está trabajando y la última hora debe estar al día.
    emit(
      ConnectivityIndicatorState(
        availability: state.availability,
        isSyncing: info.isSyncing,
        lastSyncAt: info.lastSyncAt,
      ),
    );
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    await _availabilitySubscription?.cancel();
    await _syncSubscription?.cancel();
    return super.close();
  }
}
