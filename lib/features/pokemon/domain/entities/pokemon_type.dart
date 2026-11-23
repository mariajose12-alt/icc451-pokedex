import 'package:equatable/equatable.dart';

/// Tipo elemental de un Pokémon (fuego, agua...). Entidad del dominio.
class PokemonType extends Equatable {
  const PokemonType({required this.id, required this.name});

  final int id;

  /// Nombre tal como lo devuelve PokeAPI, p. ej. "grass".
  final String name;

  @override
  List<Object?> get props => [id, name];
}
