import 'package:equatable/equatable.dart';

/// Lo que el indicador necesita saber de la sincronización (PF §7.4).
/// Es independiente de la disponibilidad del servicio.
class SyncInfo extends Equatable {
  const SyncInfo({required this.isSyncing, required this.lastSyncAt});

  /// true mientras se está actualizando la base local.
  final bool isSyncing;

  /// Última vez que se sincronizó con éxito. null si nunca ha pasado.
  final DateTime? lastSyncAt;

  @override
  List<Object?> get props => [isSyncing, lastSyncAt];
}

/// Quien sepa de la sincronización implementa esto.
/// En T-014 lo implementará el sincronizador real (con SYNC_METADATA).
abstract interface class SyncInfoSource {
  SyncInfo get current;

  /// Emite el valor actual de inmediato y luego cada cambio.
  Stream<SyncInfo> watch();
}
