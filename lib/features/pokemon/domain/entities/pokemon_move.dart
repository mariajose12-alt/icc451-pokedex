import 'package:equatable/equatable.dart';

/// Un movimiento que aprende un Pokémon, con el nivel en que lo aprende
/// (0 si el método no usa nivel).
class PokemonMove extends Equatable {
  const PokemonMove({
    required this.moveId,
    required this.name,
    required this.level,
  });

  final int moveId;

  /// Identificador de PokeAPI: 'swords-dance'.
  final String name;
  final int level;

  @override
  List<Object?> get props => [moveId, name, level];
}
