import 'package:equatable/equatable.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';

/// Estados de la pantalla de detalle.
sealed class PokemonDetailState extends Equatable {
  const PokemonDetailState();

  @override
  List<Object?> get props => [];
}

/// Todavía no llegó la primera lectura de la base.
final class PokemonDetailLoading extends PokemonDetailState {
  const PokemonDetailLoading();
}

/// El Pokémon está guardado. Se muestra y se redibuja si cambia en la base.
final class PokemonDetailSuccess extends PokemonDetailState {
  const PokemonDetailSuccess(this.pokemon);

  final Pokemon pokemon;

  @override
  List<Object?> get props => [pokemon];
}

/// Ese id no existe en la base local (por ejemplo, un enlace viejo).
final class PokemonDetailNotFound extends PokemonDetailState {
  const PokemonDetailNotFound();
}