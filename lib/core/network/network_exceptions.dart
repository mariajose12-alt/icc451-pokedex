/// Errores de infraestructura al hablar con PokeAPI
/// La capa data los traduce a fallos del dominio
sealed class PokeApiException implements Exception {
  const PokeApiException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// No hay red o no se pudo llegar al servidor.
final class NoConnectionException extends PokeApiException {
  const NoConnectionException() : super('Sin conexión a la red.');
}

/// La solicitud superó el tiempo límite.
final class RequestTimeoutException extends PokeApiException {
  const RequestTimeoutException(this.timeout)
    : super('La solicitud superó el tiempo límite.');

  final Duration timeout;
}

/// Se superó el límite de solicitudes de PokeAPI.
final class RateLimitException extends PokeApiException {
  const RateLimitException()
    : super('Se superó el límite de solicitudes de PokeAPI.');
}

/// El servidor respondió con un error HTTP.
final class ServerErrorException extends PokeApiException {
  const ServerErrorException(this.statusCode)
    : super('El servidor respondió con un error.');

  final int? statusCode;
}

/// La API devolvió errores GraphQL. Si además hay datos, es una respuesta parcial.
final class GraphQlResponseException extends PokeApiException {
  const GraphQlResponseException(this.errors, {this.partialData})
    : super('La API devolvió errores GraphQL.');

  final List<String> errors;
  final Map<String, dynamic>? partialData;
}

/// Cualquier otro fallo no previsto.
final class UnexpectedNetworkException extends PokeApiException {
  const UnexpectedNetworkException(super.message);
}
