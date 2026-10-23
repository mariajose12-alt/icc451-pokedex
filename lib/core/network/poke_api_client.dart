import 'dart:async';

import 'package:graphql/client.dart';

import 'network_exceptions.dart';

/// Cliente de PokeAPI. Ejecuta una consulta y devuelve los datos,
/// o lanza una [PokeApiException] tipada.
class PokeApiClient {
  PokeApiClient({required this.url, required this.timeout})
    : _client = GraphQLClient(link: HttpLink(url), cache: GraphQLCache());

  final String url;
  final Duration timeout;
  final GraphQLClient _client;

  Future<Map<String, dynamic>> query(
    String document, {
    Map<String, dynamic> variables = const <String, dynamic>{},
  }) async {
    final options = QueryOptions<Object?>(
      document: gql(document),
      variables: variables,
      // La base local es la fuente de verdad: nunca leer ni guardar en la caché del cliente.
      fetchPolicy: FetchPolicy.noCache,
    );

    // 1. Ejecutar con timeout explícito.
    final QueryResult<Object?> result;
    try {
      result = await _client.query(options).timeout(timeout);
    } on TimeoutException {
      throw RequestTimeoutException(timeout);
    }

    // 2. Clasificar el error, si lo hay.
    if (result.hasException) {
      final exception = result.exception!;
      final link = exception.linkException;

      if (link is NetworkException) {
        throw const NoConnectionException();
      }

      if (link is ServerException) {
        final status = link.statusCode;
        if (status == 429) {
          throw const RateLimitException();
        }
        throw ServerErrorException(status);
      }

      if (exception.graphqlErrors.isNotEmpty) {
        final messages = <String>[];
        for (final error in exception.graphqlErrors) {
          messages.add(error.message);
        }
        // Si también llegaron datos, es una respuesta parcial.
        throw GraphQlResponseException(messages, partialData: result.data);
      }

      throw UnexpectedNetworkException(exception.toString());
    }

    // 3. Sin errores, pero sin datos.
    final data = result.data;
    if (data == null) {
      throw const UnexpectedNetworkException('La respuesta no contiene datos.');
    }

    return data;
  }
}
