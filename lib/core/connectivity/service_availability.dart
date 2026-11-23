/// Disponibilidad real del servicio GraphQL (PF §7.1 y §7.4).
/// Es independiente de la actividad de sincronización.
enum ServiceAvailability {
  /// Aún no se ha completado la primera comprobación.
  checking,

  /// Hay red y la API respondió correctamente.
  online,

  /// No hay conectividad de red.
  offline,

  /// Hay red, pero la API no respondió bien (error, timeout o límite de tasa).
  serviceUnavailable,
}
