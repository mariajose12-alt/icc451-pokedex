/// Favoritos del usuario (RF-FAV-01). Solo lee de la base local y escribe en
/// ella: no hay red de por medio.
abstract interface class FavoritesRepository {
  /// ¿Este Pokémon es favorito? Emite otra vez cuando cambia.
  Stream<bool> watchIsFavorite(int pokemonId);

  /// Ids de todos los favoritos. Para el catálogo y la pantalla de favoritos.
  Stream<Set<int>> watchFavoriteIds();

  /// Agrega o quita. Devuelve el estado nuevo: true si quedó como favorito.
  Future<bool> toggle(int pokemonId);
}