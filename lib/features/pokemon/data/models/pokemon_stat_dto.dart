/// Una estadistica base como llega de PokeAPI (campo pokemonstats)
class PokemonStatDto {
  const PokemonStatDto({required this.statName, required this.baseStat});

  /// Nombre de PokeAPI: hp, attack, defense, special-attack, special-defense
  /// o speed
  final String statName;

  /// Valor base de la estadistica
  final int baseStat;

  /// Constructor para convertir de json a objeto
  factory PokemonStatDto.fromJson(Map<String, dynamic> json) {
    return PokemonStatDto(
      // Si el formato cambia, el cast falla con TypeError. La fuente
      // remota lo convierte en eun error de infraestructura.
      statName: (json['stat'] as Map<String, dynamic>)['name'] as String,
      baseStat: json['base_stat'] as int,
    );
  }
}
