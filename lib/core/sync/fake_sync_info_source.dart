import 'dart:async';

import 'sync_info.dart';

/// TEMPORAL: fuente falsa hasta que exista el sincronizador (T-014).
class FakeSyncInfoSource implements SyncInfoSource {
  FakeSyncInfoSource({DateTime? lastSyncAt})
    : _current = SyncInfo(isSyncing: false, lastSyncAt: lastSyncAt);

  final StreamController<SyncInfo> _controller =
      StreamController<SyncInfo>.broadcast();

  SyncInfo _current;

  @override
  SyncInfo get current => _current;

  @override
  Stream<SyncInfo> watch() async* {
    yield _current;
    yield* _controller.stream;
  }

  /// Sirve para simular una sincronización en una prueba o demo.
  void emit(SyncInfo info) {
    _current = info;
    _controller.add(info);
  }
}
