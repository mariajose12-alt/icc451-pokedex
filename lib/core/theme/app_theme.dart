import 'package:flutter/material.dart';

import 'pixel_palette.dart';

/// Tema de la aplicación: Pokédex pixelada, oscura. No hay tema claro: la
/// interfaz imita la pantalla de una Pokédex.
abstract final class AppTheme {
  static const String fontFamily = 'PixelifySans';

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: fontFamily,
    scaffoldBackgroundColor: PixelPalette.background,
    colorScheme: const ColorScheme.dark(
      primary: PixelPalette.accent,
      onPrimary: PixelPalette.background,
      secondary: PixelPalette.lens,
      onSecondary: PixelPalette.background,
      // Los botones segmentados seleccionados usan este par (amarillo).
      secondaryContainer: PixelPalette.accent,
      onSecondaryContainer: PixelPalette.background,
      surface: PixelPalette.panel,
      onSurface: PixelPalette.text,
      onSurfaceVariant: PixelPalette.textMuted,
      surfaceContainerHighest: PixelPalette.panelHigh,
      outline: PixelPalette.panelBorder,
      error: Color(0xFFFF8A80),
      onError: PixelPalette.background,
      errorContainer: Color(0xFF5C2128),
      onErrorContainer: PixelPalette.text,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: PixelPalette.shell,
      foregroundColor: PixelPalette.text,
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: PixelPalette.panel,
      surfaceTintColor: Colors.transparent,
      indicatorColor: PixelPalette.accent,
      indicatorShape: RoundedRectangleBorder(),
    ),
    // Mantiene objetivos táctiles de al menos 48x48 dp (RNF-ACC-03).
    materialTapTargetSize: MaterialTapTargetSize.padded,
  );
}
