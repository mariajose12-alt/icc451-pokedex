import 'dart:async';

import 'package:pokedex/features/pokemon/domain/entities/catalogo_query.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_repository.dart';

/// Repositorio falso para probar el detalle. La prueba decide qué emite la
/// "base" con [pokemonController]: add(pokemon) simula un Pokémon guardado,
/// add(null) simula que no existe.
class ControllablePokemonRepository implements PokemonRepository {
  final StreamController<Pokemon?> pokemonController =
      StreamController<Pokemon?>();

  /// Último id que se pidió observar. Sirve para comprobar que el id de la
  /// ruta llega hasta el repositorio.
  int? lastRequestedId;

  @override
  Stream<Pokemon?> watchPokemon(int id) {
    lastRequestedId = id;
    return pokemonController.stream;
  }

  @override
  Stream<List<Pokemon>> watchCatalog() => const Stream<List<Pokemon>>.empty();

  @override
  Future<void> refreshCatalog({bool onlyIfStale = false}) async {}

  @override
  Stream<List<Pokemon>> watchCatalogoFiltrado(CatalogoQuery query) =>
      watchCatalog();
}
