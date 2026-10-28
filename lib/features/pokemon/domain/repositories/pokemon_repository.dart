import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';

/// Contrato de acceso al catálogo de Pokémon. Lo implementa la capa data;
/// la presentación solo conoce esta interfaz (OF-17, OF-18).
abstract interface class PokemonRepository {
  /// Observa el catálogo guardado en la base local, ordenado por número
  /// de Pokédex. Emite un valor nuevo cada vez que la base cambia (OF-16).
  /// Si todavía no hay datos, emite una lista vacía.
  Stream<List<Pokemon>> watchCatalog();

  /// Pide a la fuente remota que actualice el catálogo local.
  /// Completa cuando termina y lanza un [Failure] si no se pudo.
  /// Un fallo nunca borra los datos locales válidos (OF-04).
  ///
  /// Si [onlyIfStale] es true (actualización automática), no hace nada
  /// cuando los datos locales todavía están vigentes (PS-03). Con false
  /// (actualización manual) siempre sincroniza.
  Future<void> refreshCatalog({bool onlyIfStale = false});
}
