import 'package:equatable/equatable.dart';
import 'package:pokedex/core/connectivity/service_availability.dart';

/// Todo lo que el widget necesita para dibujarse.
/// Son dos dimensiones separadas: disponibilidad y sincronización.
class ConnectivityIndicatorState extends Equatable {
  const ConnectivityIndicatorState({
    required this.availability,
    required this.isSyncing,
    required this.lastSyncAt,
  });

  final ServiceAvailability availability;
  final bool isSyncing;
  final DateTime? lastSyncAt;

  @override
  List<Object?> get props => [availability, isSyncing, lastSyncAt];
}
