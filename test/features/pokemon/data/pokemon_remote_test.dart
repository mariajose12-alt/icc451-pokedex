import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/network/network_exceptions.dart';
import 'package:pokedex/core/network/poke_api_client.dart';
import 'package:pokedex/features/pokemon/data/datasources/remote/pokemon_remote_datasource.dart';
import 'package:pokedex/features/pokemon/data/models/pokemon_mapper.dart';

// Cliente falso: devuelve lo que le digamos y recuerda con qué lo llamaron.
class FakeApiClient implements PokeApiClient {
  Map<String, dynamic>? response;
  Map<String, dynamic>? lastVariables;

  @override
  final String url = 'fake';

  @override
  final Duration timeout = const Duration(seconds: 1);

  @override
  Future<Map<String, dynamic>> query(
    String document, {
    Map<String, dynamic> variables = const <String, dynamic>{},
  }) async {
    lastVariables = variables;
    return response!;
  }
}

// Respuesta de ejemplo con la forma de la query (Pikachu, tipo eléctrico).
Map<String, dynamic> sampleResponse() {
  return <String, dynamic>{
    'pokemon': <dynamic>[
      <String, dynamic>{
        'id': 25,
        'name': 'pikachu',
        'height': 4,
        'weight': 60,
        'pokemonsprites': <dynamic>[
          <String, dynamic>{
            'artwork': 'https://example.com/25-art.png',
            'sprite': 'https://example.com/25.png',
          },
        ],
        'pokemontypes': <dynamic>[
          <String, dynamic>{
            'slot': 1,
            'type': <String, dynamic>{'id': 13, 'name': 'electric'},
          },
        ],
        'pokemonspecy': <String, dynamic>{'id': 25, 'generation_id': 1},
      },
    ],
    'pokemon_aggregate': <String, dynamic>{
      'aggregate': <String, dynamic>{'count': 1025},
    },
  };
}

void main() {
  late FakeApiClient client;
  late PokemonRemoteDataSource dataSource;

  setUp(() {
    client = FakeApiClient();
    dataSource = PokemonRemoteDataSource(client: client);
  });

  test('envía el cursor y el tamaño de página como variables', () async {
    client.response = sampleResponse();
    await dataSource.fetchCatalogPage(afterId: 3, pageSize: 2);

    expect(client.lastVariables, <String, dynamic>{'lastId': 3, 'pageSize': 2});
  });

  test('convierte la respuesta en un DTO con el total remoto', () async {
    client.response = sampleResponse();
    final page = await dataSource.fetchCatalogPage(afterId: 0);

    expect(page.totalCount, 1025);
    expect(page.items.length, 1);
    expect(page.items.first.name, 'pikachu');
    expect(page.items.first.generationId, 1);
  });

  test('el mapeador produce la entidad del dominio', () async {
    client.response = sampleResponse();
    final page = await dataSource.fetchCatalogPage(afterId: 0);
    final pokemon = page.items.first.toDomain();

    expect(pokemon.id, 25);
    expect(pokemon.nationalDexNumber, 25);
    expect(pokemon.types.single.name, 'electric');
    expect(pokemon.artworkUrl, 'https://example.com/25-art.png');
  });

  test('una imagen que falta queda en null y no rompe la lectura', () async {
    final response = sampleResponse();
    final first =
        (response['pokemon'] as List<dynamic>).first as Map<String, dynamic>;
    first['pokemonsprites'] = <dynamic>[
      <String, dynamic>{'artwork': null, 'sprite': null},
    ];
    client.response = response;

    final page = await dataSource.fetchCatalogPage(afterId: 0);

    expect(page.items.first.artworkUrl, isNull);
    expect(page.items.first.spriteUrl, isNull);
  });

  test('un formato inesperado se convierte en un error tipado', () async {
    client.response = <String, dynamic>{'pokemon': 'esto no es una lista'};

    expect(
      () => dataSource.fetchCatalogPage(afterId: 0),
      throwsA(isA<UnexpectedNetworkException>()),
    );
  });
}
