import 'package:equatable/equatable.dart';

/// Una pregunta de la trivia: el Pokémon que hay que adivinar.
/// Entidad del dominio: no depende de Flutter ni de Drift.
class TriviaQuestion extends Equatable {
  const TriviaQuestion({
    required this.pokemonId,
    required this.name,
    required this.nationalDexNumber,
    required this.typeNames,
    this.artworkUrl,
    this.spriteUrl,
  });

  final int pokemonId;

  /// Nombre tal como lo guarda PokeAPI, p. ej. "mr-mime".
  final String name;
  final int nationalDexNumber;
  final List<String> typeNames;
  final String? artworkUrl;
  final String? spriteUrl;

  /// Imagen oficial y, si falta, el sprite (igual que RF-DET-01).
  String? get imageUrl => artworkUrl ?? spriteUrl;

  @override
  List<Object?> get props => [
    pokemonId,
    name,
    nationalDexNumber,
    typeNames,
    artworkUrl,
    spriteUrl,
  ];
}
