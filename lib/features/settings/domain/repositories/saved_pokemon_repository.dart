/// Lo que Ajustes necesita saber de los Pokémon guardados en el teléfono.
/// La presentación solo conoce esta interfaz (OF-17, OF-18).
abstract interface class SavedPokemonRepository {
  /// Cuántos Pokémon hay en la base local. Emite cada vez que cambia.
  Stream<int> watchCount();

  /// Direcciones de sprites de Pokémon al azar (solo decoración).
  Future<List<String>> randomSpriteUrls(int limit);
}
