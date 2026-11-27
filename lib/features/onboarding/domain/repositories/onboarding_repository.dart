/// Recuerda si el usuario ya vio la introducción (RF-COM-08).
/// La presentación solo conoce esta interfaz.
abstract interface class OnboardingRepository {
  /// true si la introducción ya se mostró y se terminó o se saltó.
  bool get hasSeen;

  /// Marca la introducción como vista.
  Future<void> markSeen();
}
