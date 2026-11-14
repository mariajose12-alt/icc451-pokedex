/// Rutas de la aplicación. Vive en su propio archivo, sin imports, para que
/// tanto el router como las pantallas lo usen sin crear dependencias
/// circulares.
abstract final class AppRoutes {
  static const String catalog = '/catalog';
  static const String favorites = '/favorites';

  /// Último tramo de la ruta del detalle. Va dentro de la ruta del catálogo,
  /// y ':id' es el parámetro con el id del Pokémon.
  static const String pokemonDetailSegment = ':id';

  /// Ruta completa del detalle de un Pokémon, p. ej. /catalog/25.
  static String pokemonDetail(int id) => '$catalog/$id';
}