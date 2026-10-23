import 'package:flutter/material.dart';

/// Par de colores de un tipo de Pokémon. El texto tiene un contraste
/// mínimo de 4.5:1 sobre el fondo (WCAG 2.1 AA, RNF-ACC-02).
class TypeColor {
  const TypeColor(this.background, this.foreground);

  final Color background;
  final Color foreground;
}

/// Paleta de los tipos de Pokémon, indexada por el nombre que devuelve PokeAPI.
///
/// Uso: PokemonTypeColors.byName[nombre] ?? PokemonTypeColors.fallback
abstract final class PokemonTypeColors {
  static const Color _textOnLight = Color(0xFF1B1B1F);
  static const Color _textOnDark = Color(0xFFFFFFFF);

  /// Se usa cuando el tipo no está en la tabla.
  static const TypeColor fallback = TypeColor(Color(0xFF9E9E9E), _textOnLight);

  static const Map<String, TypeColor> byName = <String, TypeColor>{
    'normal': TypeColor(Color(0xFFA8A77A), _textOnLight),
    'fire': TypeColor(Color(0xFFEE8130), _textOnLight),
    'water': TypeColor(Color(0xFF6390F0), _textOnLight),
    'electric': TypeColor(Color(0xFFF7D02C), _textOnLight),
    'grass': TypeColor(Color(0xFF7AC74C), _textOnLight),
    'ice': TypeColor(Color(0xFF96D9D6), _textOnLight),
    'fighting': TypeColor(Color(0xFFC22E28), _textOnDark),
    'poison': TypeColor(Color(0xFFA33EA1), _textOnDark),
    'ground': TypeColor(Color(0xFFE2BF65), _textOnLight),
    'flying': TypeColor(Color(0xFFA98FF3), _textOnLight),
    'psychic': TypeColor(Color(0xFFF95587), _textOnLight),
    'bug': TypeColor(Color(0xFFA6B91A), _textOnLight),
    'rock': TypeColor(Color(0xFFB6A136), _textOnLight),
    'ghost': TypeColor(Color(0xFF735797), _textOnDark),
    'dragon': TypeColor(Color(0xFF6F35FC), _textOnDark),
    'dark': TypeColor(Color(0xFF705746), _textOnDark),
    'steel': TypeColor(Color(0xFFB7B7CE), _textOnLight),
    'fairy': TypeColor(Color(0xFFD685AD), _textOnLight),
    // Tipos especiales que PokeAPI también define.
    'stellar': TypeColor(Color(0xFF40B5A8), _textOnLight),
    'unknown': TypeColor(Color(0xFF68A090), _textOnLight),
    'shadow': TypeColor(Color(0xFF4A3F6B), _textOnDark),
  };
}
