/// Fallos que la capa de dominio y la presentación entienden.
/// La capa data traduce las excepciones de infraestructura a estos tipos.
sealed class Failure implements Exception {
  const Failure(this.message);

  final String message;
}

/// No hay conexión a la red.
final class NoConnectionFailure extends Failure {
  const NoConnectionFailure() : super('Sin conexión a la red.');
}

/// La solicitud tardó demasiado.
final class TimeoutFailure extends Failure {
  const TimeoutFailure() : super('La solicitud tardó demasiado.');
}

/// Se superó el límite de solicitudes de PokeAPI.
final class RateLimitFailure extends Failure {
  const RateLimitFailure() : super('Demasiadas solicitudes a PokeAPI.');
}

/// El servicio respondió con un error o con datos inválidos.
final class ServiceFailure extends Failure {
  const ServiceFailure() : super('El servicio no está disponible.');
}

/// Cualquier otro fallo no previsto.
final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Ocurrió un error inesperado.']);
}
