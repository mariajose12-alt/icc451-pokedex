import 'package:pokedex/core/network/network_exceptions.dart';
import 'package:pokedex/core/network/poke_api_client.dart';

// API falsa con [total] Pokémon (ids 1..total). Responde según el cursor
// que reciba, igual que la API real, y recuerda cada llamada.
class FakeCatalogApi implements PokeApiClient {
  FakeCatalogApi({required this.total});

  final int total;

  /// Valores de lastId con los que se llamó, en orden.
  final List<int> calls = <int>[];

  /// Número de llamada (1, 2, 3...) en la que debe fallar. null = nunca.
  int? failOnCall;

  @override
  final String url = 'fake';

  @override
  final Duration timeout = const Duration(seconds: 1);

  @override
  Future<Map<String, dynamic>> query(
    String document, {
    Map<String, dynamic> variables = const <String, dynamic>{},
  }) async {
    final lastId = variables['lastId'] as int;
    final pageSize = variables['pageSize'] as int;
    calls.add(lastId);

    if (failOnCall == calls.length) {
      throw const NoConnectionException();
    }

    final items = <Map<String, dynamic>>[];
    for (var id = lastId + 1; id <= total && items.length < pageSize; id++) {
      items.add(<String, dynamic>{
        'id': id,
        'name': 'pokemon-$id',
        'height': 1,
        'weight': 1,
        'pokemonsprites': <dynamic>[
          <String, dynamic>{'artwork': 'a$id.png', 'sprite': 's$id.png'},
        ],
        'pokemontypes': <dynamic>[
          <String, dynamic>{
            'slot': 1,
            'type': <String, dynamic>{'id': 12, 'name': 'grass'},
          },
        ],
        'pokemonspecy': <String, dynamic>{'id': id, 'generation_id': 1},
      });
    }

    return <String, dynamic>{
      'pokemon': items,
      'pokemon_aggregate': <String, dynamic>{
        'aggregate': <String, dynamic>{'count': total},
      },
    };
  }
}
