import 'package:pokedex/core/errors/failures.dart';
import 'package:pokedex/core/network/network_exceptions.dart';

/// Traduce los errores de infraestructura (PokeApiException) a los fallos
/// que entiende el dominio y la presentación (Failure).
/// Solo la capa data lo usa: la UI nunca ve una PokeApiException.
extension PokeApiExceptionMapper on PokeApiException {
  Failure toFailure() {
    // `switch` sobre una clase sellada: si algún día se agrega una excepción
    // nueva y no se contempla aquí, el compilador avisa.
    return switch (this) {
      NoConnectionException() => const NoConnectionFailure(),
      RequestTimeoutException() => const TimeoutFailure(),
      RateLimitException() => const RateLimitFailure(),
      ServerErrorException() => const ServiceFailure(),
      GraphQlResponseException() => const ServiceFailure(),
      UnexpectedNetworkException() => const ServiceFailure(),
    };
  }
}
