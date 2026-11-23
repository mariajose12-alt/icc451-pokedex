import 'service_availability.dart';

/// Contrato del monitor de disponibilidad. La UI y los Blocs dependen de
/// esto y no de la implementación (RNF-MAN-03: dependencias sustituibles).
abstract interface class ConnectivityMonitor {
  /// Último estado conocido.
  ServiceAvailability get current;

  /// Emite el estado actual de inmediato y luego cada cambio.
  Stream<ServiceAvailability> watch();

  /// Empieza a escuchar la red y hace la primera comprobación.
  Future<void> start();

  /// Fuerza una comprobación ahora (por ejemplo, al abrir un detalle, OF-20).
  Future<void> checkNow();

  Future<void> dispose();
}
