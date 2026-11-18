import 'package:equatable/equatable.dart';

/// Una habilidad de un Pokémon (RF-DET-03).
class PokemonAbility extends Equatable {
  const PokemonAbility({
    required this.id,
    required this.name,
    required this.nameEs,
    required this.nameEn,
    required this.effectSummary,
    required this.isHidden,
  });

  final int id;

  /// Identificador de PokeAPI, por ejemplo 'overgrow'.
  final String name;
  final String? nameEs;
  final String? nameEn;

  /// Efecto en inglés, de 160 caracteres como máximo. Null si no hay texto.
  final String? effectSummary;
  final bool isHidden;

  /// Nombre en el idioma pedido ('es' o 'en'). Si falta, se usa el otro idioma
  /// y, en último caso, el identificador.
  String displayName(String languageCode) {
    final preferred = languageCode == 'es' ? nameEs : nameEn;
    return preferred ?? nameEn ?? nameEs ?? name;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    nameEs,
    nameEn,
    effectSummary,
    isHidden,
  ];
}
