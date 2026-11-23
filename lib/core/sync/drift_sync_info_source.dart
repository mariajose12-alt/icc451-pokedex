import 'dart:async';

import 'package:pokedex/core/async/current_then_changes.dart';
import 'package:pokedex/core/database/daos/catalogo_dao.dart';

import 'sync_info.dart';

/// Fuente real de [SyncInfo] para el indicador global (reemplaza a la falsa).
///  - `lastSyncAt` sale de la base (SYNC_METADATA), así sobrevive al reinicio.
///  - `isSyncing` sale del sincronizador en memoria. No se lee de la base
///    porque, si la app se cierra a mitad, el estado `syncing` quedaría
///    guardado y el indicador mostraría «Sincronizando» para siempre.
class DriftSyncInfoSource implements SyncInfoSource {
  DriftSyncInfoSource({
    required CatalogoDao dao,
    required String resourceKey,
    required Stream<bool> runningChanges,
    required bool initiallyRunning,
  }) : _isSyncing = initiallyRunning {
    _current = SyncInfo(isSyncing: _isSyncing, lastSyncAt: null);
    _dbSubscription = dao.watchSyncState(resourceKey).listen((state) {
      _lastSyncAt = state?.lastSuccessfulAt;
      _publish();
    });
    _runSubscription = runningChanges.listen((running) {
      _isSyncing = running;
      _publish();
    });
  }

  final StreamController<SyncInfo> _controller =
      StreamController<SyncInfo>.broadcast();

  late final StreamSubscription<Object?> _dbSubscription;
  late final StreamSubscription<bool> _runSubscription;

  late SyncInfo _current;
  bool _isSyncing;
  DateTime? _lastSyncAt;

  @override
  SyncInfo get current => _current;

  @override
  Stream<SyncInfo> watch() {
    return currentThenChanges(
      current: () => _current,
      changes: _controller.stream,
    );
  }

  // Solo emite si algo cambió de verdad (SyncInfo es Equatable).
  void _publish() {
    final next = SyncInfo(isSyncing: _isSyncing, lastSyncAt: _lastSyncAt);
    if (next == _current) {
      return;
    }
    _current = next;
    _controller.add(next);
  }

  Future<void> dispose() async {
    await _dbSubscription.cancel();
    await _runSubscription.cancel();
    await _controller.close();
  }
}
