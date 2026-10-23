/// Constantes de conexión con PokeAPI
abstract final class ApiConfig {
  static const String graphqlUrl = 'https://graphql.pokeapi.co/v1beta2';

  // Tiempo máximo de espera de una solicitud
  static const Duration requestTimeout = Duration(seconds: 20);
}
