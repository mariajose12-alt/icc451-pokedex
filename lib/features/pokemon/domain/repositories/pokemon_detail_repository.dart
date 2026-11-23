import 'package:pokedex/features/pokemon/domain/entities/pokemon_extras.dart';

/// Datos del detalle de un Pokémon que se descargan al abrirlo: habilidades,
/// evoluciones, formas... Es un contrato aparte de PokemonRepository para no
/// obligar a todos sus falsos a implementar métodos nuevos.
abstract interface class PokemonDetailRepository {
  /// Pide el detalle a PokeAPI y lo guarda en la base local. La pantalla no
  /// recibe la respuesta: se entera porque la base emite (OF-16).
  /// Lanza un Failure si no se pudo.
  Future<void> refreshDetail(int pokemonId);

  /// Observa lo descargado de un Pokémon. Emite [PokemonExtras.empty] mientras
  /// no se haya descargado.
  Stream<PokemonExtras> watchExtras(int pokemonId);
}
