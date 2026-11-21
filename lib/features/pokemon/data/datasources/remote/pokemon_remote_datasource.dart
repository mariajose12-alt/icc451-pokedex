import 'package:pokedex/core/network/network_exceptions.dart';
import 'package:pokedex/core/network/poke_api_client.dart';
import 'package:pokedex/features/pokemon/data/models/pokemon_dto.dart';
import 'package:pokedex/features/pokemon/data/models/type_efficacy_dto.dart';
import 'package:flutter/foundation.dart';
import 'package:pokedex/features/pokemon/data/models/pokemon_detail_dto.dart';

import 'pokemon_queries.dart';

/// Pide datos a PokeAPI y los devuelve como DTOs.
/// Lanza [PokeApiException]; la traducción a Failure la hace el repositorio.
class PokemonRemoteDataSource {
  PokemonRemoteDataSource({required this._client});

  final PokeApiClient _client;

  /// Tamaño de página: 1025 Pokémon se descargan en 5 llamadas,
  /// muy por debajo del límite de 100 por hora.
  static const int defaultPageSize = 250;

  /// Trae la página que viene después de [afterId] (0 para la primera).
  Future<CatalogPageDto> fetchCatalogPage({
    required int afterId,
    int pageSize = defaultPageSize,
  }) async {
    // 1. Pedir a la API (puede lanzar PokeApiException).
    final data = await _client.query(
      PokemonQueries.catalogPage,
      variables: <String, dynamic>{'lastId': afterId, 'pageSize': pageSize},
    );

    // 2. Convertir el JSON a DTO. Si la API cambia de formato, el fallo
    // es de infraestructura: se avisa con un error tipado, no con un crash.
    try {
      return CatalogPageDto.fromJson(data);
    } on TypeError catch (error) {
      throw UnexpectedNetworkException('Formato inesperado: $error');
    } on FormatException catch (error) {
      throw UnexpectedNetworkException('Formato inesperado: $error');
    }
  }

  /// Trae la tabla completa de efectividades entre tipos (una llamada).
  Future<List<TypeEfficacyDto>> fetchTypeEfficacies() async {
    final data = await _client.query(PokemonQueries.typeEfficacies);

    // Igual que en el catálogo: un formato inesperado es un error tipado.
    try {
      return TypeEfficacyDto.listFromJson(data);
    } on TypeError catch (error) {
      throw UnexpectedNetworkException('Formato inesperado: $error');
    } on FormatException catch (error) {
      throw UnexpectedNetworkException('Formato inesperado: $error');
    }
  }

  /// Trae todo el detalle de un Pokémon en una sola llamada (PA-02).
  Future<PokemonDetailDto> fetchPokemonDetail(int id) async {
    // PA-02 pide dejar registro en consola de la consulta GraphQL.
    debugPrint('GraphQL: consultando el detalle del Pokémon $id');

    final data = await _client.query(
      PokemonQueries.pokemonDetail,
      variables: <String, dynamic>{'id': id},
    );

    // Un formato inesperado (o un id que no existe) es un error tipado.
    try {
      return PokemonDetailDto.fromJson(data);
    } on TypeError catch (error) {
      throw UnexpectedNetworkException('Formato inesperado: $error');
    } on FormatException catch (error) {
      throw UnexpectedNetworkException('Formato inesperado: $error');
    }
  }
}
