import 'package:flutter/foundation.dart';
import 'package:pokedex/core/network/api_outage_simulator.dart';
import 'package:pokedex/core/network/network_exceptions.dart';
import 'package:pokedex/core/network/poke_api_client.dart';

/// Cliente de PokeAPI que puede fingir una caída del servidor.
/// Con la caída apagada se comporta exactamente como [PokeApiClient].
class SimulatedOutagePokeApiClient extends PokeApiClient {
  SimulatedOutagePokeApiClient({
    required super.url,
    required super.timeout,
    required this.simulator,
  });

  final ApiOutageSimulator simulator;

  @override
  Future<Map<String, dynamic>> query(
    String document, {
    Map<String, dynamic> variables = const <String, dynamic>{},
  }) async {
    if (simulator.isDown) {
      // Una pausa corta, como un servidor real que tarda en contestar.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      debugPrint('Simulador: API caída, llamada rechazada con error 503');
      throw const ServerErrorException(503);
    }

    // Caída apagada: se usa el cliente real.
    return super.query(document, variables: variables);
  }
}
