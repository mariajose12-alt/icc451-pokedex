import 'package:flutter/material.dart';

/// Colores de la interfaz «Pokédex pixelada». Todos los pares de texto y fondo
/// cumplen un contraste mínimo de 4.5:1 (WCAG 2.1 AA, RNF-ACC-02).
abstract final class PixelPalette {
  /// Fondo de pantalla.
  static const Color background = Color(0xFF141A2E);

  /// Tarjetas y barra de navegación.
  static const Color panel = Color(0xFF1F2847);

  /// Botones inactivos.
  static const Color panelHigh = Color(0xFF2B3863);

  /// Borde de las tarjetas.
  static const Color panelBorder = Color(0xFF4A5D9B);

  /// Sombra dura y campos de texto.
  static const Color shadow = Color(0xFF0B0F1C);

  /// Carcasa roja de la Pokédex.
  static const Color shell = Color(0xFFC83838);
  static const Color shellDark = Color(0xFF8A2424);

  /// Amarillo: elemento activo y favoritos.
  static const Color accent = Color(0xFFF8C830);

  /// Lente azul de la Pokédex.
  static const Color lens = Color(0xFF48A0F8);

  static const Color text = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFA8B3D0);
}
