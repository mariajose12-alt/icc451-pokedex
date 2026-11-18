import 'package:pokedex/core/network/network_exceptions.dart';
import 'package:pokedex/core/network/poke_api_client.dart';

import 'pokemon_detail_sample.dart';

// API falsa del detalle: responde con el ejemplo de Bulbasaur y recuerda los
// ids que le pidieron.
class FakeDetailApi implements PokeApiClient {
  /// Ids con los que se llamó, en orden.
  final List<int> calls = <int>[];

  /// Si no es null, la llamada falla con este error.
  PokeApiException? failWith;

  @override
  final String url = 'fake';

  @override
  final Duration timeout = const Duration(seconds: 1);

  @override
  Future<Map<String, dynamic>> query(
    String document, {
    Map<String, dynamic> variables = const <String, dynamic>{},
  }) async {
    calls.add(variables['id'] as int);

    final error = failWith;
    if (error != null) {
      throw error;
    }
    return sampleDetail();
  }
}
