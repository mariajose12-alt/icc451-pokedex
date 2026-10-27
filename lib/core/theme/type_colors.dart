import 'package:flutter/material.dart';

/// Colores e icono de un tipo de Pokémon. El texto tiene un contraste mínimo
/// de 5.5:1 sobre el fondo (WCAG 2.1 AA, RNF-ACC-02). El tipo nunca se
/// comunica solo con color: siempre lleva texto e icono (RNF-ACC-05).
class TypeColor {
  const TypeColor(this.background, this.foreground, this.icon);

  final Color background;
  final Color foreground;
  final IconData icon;
}

/// Paleta clásica de los tipos, indexada por el nombre que devuelve PokeAPI.
///
/// Uso: PokemonTypeColors.byName[nombre] ?? PokemonTypeColors.fallback
abstract final class PokemonTypeColors {
  static const Color _textOnLight = Color(0xFF141A2E);
  static const Color _textOnDark = Color(0xFFFFFFFF);

  /// Se usa cuando el tipo no está en la tabla.
  static const TypeColor fallback = TypeColor(
    Color(0xFF9E9E9E),
    _textOnLight,
    Icons.help_outline,
  );

  static const Map<String, TypeColor> byName = <String, TypeColor>{
    'normal': TypeColor(Color(0xFFA8A878), _textOnLight, Icons.circle_outlined),
    'fire': TypeColor(
      Color(0xFFF08030),
      _textOnLight,
      Icons.local_fire_department,
    ),
    'water': TypeColor(Color(0xFF6890F0), _textOnLight, Icons.water_drop),
    'electric': TypeColor(Color(0xFFF8D030), _textOnLight, Icons.bolt),
    'grass': TypeColor(Color(0xFF78C850), _textOnLight, Icons.eco),
    'ice': TypeColor(Color(0xFF98D8D8), _textOnLight, Icons.ac_unit),
    'fighting': TypeColor(Color(0xFFC03028), _textOnDark, Icons.sports_mma),
    'poison': TypeColor(Color(0xFFA040A0), _textOnDark, Icons.science),
    'ground': TypeColor(Color(0xFFE0C068), _textOnLight, Icons.terrain),
    'flying': TypeColor(Color(0xFFA890F0), _textOnLight, Icons.air),
    'psychic': TypeColor(Color(0xFFF85888), _textOnLight, Icons.psychology),
    'bug': TypeColor(Color(0xFFA8B820), _textOnLight, Icons.bug_report),
    'rock': TypeColor(Color(0xFFB8A038), _textOnLight, Icons.landscape),
    'ghost': TypeColor(Color(0xFF705898), _textOnDark, Icons.blur_on),
    'dragon': TypeColor(Color(0xFF7038F8), _textOnDark, Icons.whatshot),
    'dark': TypeColor(Color(0xFF705848), _textOnDark, Icons.dark_mode),
    'steel': TypeColor(Color(0xFFB8B8D0), _textOnLight, Icons.settings),
    'fairy': TypeColor(Color(0xFFEE99AC), _textOnLight, Icons.auto_awesome),
    // Tipos especiales que PokeAPI también define.
    'stellar': TypeColor(Color(0xFF40B5A8), _textOnLight, Icons.star),
    'unknown': TypeColor(Color(0xFF68A090), _textOnLight, Icons.help_outline),
    'shadow': TypeColor(Color(0xFF4A3F6B), _textOnDark, Icons.nights_stay),
  };
}
