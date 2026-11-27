import 'package:flutter/material.dart';

import 'pixel_colors.dart';

/// Temas de la aplicación: Pokédex pixelada, en versión oscura y clara
/// (RF-COM-06). Los dos se construyen con la misma función, solo cambian los
/// colores de [PixelColors].
abstract final class AppTheme {
  static const String fontFamily = 'PixelifySans';

  static final ThemeData dark = _build(
    brightness: Brightness.dark,
    colors: PixelColors.dark,
  );

  static final ThemeData light = _build(
    brightness: Brightness.light,
    colors: PixelColors.light,
  );

  static ThemeData _build({
    required Brightness brightness,
    required PixelColors colors,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: colors.background,
      // Así `context.pixel` encuentra los colores propios de la app.
      extensions: <ThemeExtension<dynamic>>[colors],
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.accent,
        onPrimary: colors.onAccent,
        secondary: colors.lens,
        onSecondary: colors.onAccent,
        // Los botones segmentados seleccionados usan este par (amarillo).
        secondaryContainer: colors.accent,
        onSecondaryContainer: colors.onAccent,
        surface: colors.panel,
        onSurface: colors.text,
        onSurfaceVariant: colors.textMuted,
        surfaceContainerHighest: colors.panelHigh,
        outline: colors.panelBorder,
        error: isDark ? const Color(0xFFFF8A80) : const Color(0xFFB3261E),
        onError: isDark ? colors.background : const Color(0xFFFFFFFF),
        errorContainer: isDark
            ? const Color(0xFF5C2128)
            : const Color(0xFFFFDAD6),
        onErrorContainer: isDark ? colors.text : const Color(0xFF410002),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.shell,
        foregroundColor: colors.onShell,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.panel,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colors.accent,
        indicatorShape: const RoundedRectangleBorder(),
      ),
      // Los botones de texto usan el amarillo "para texto", que en el tema
      // claro es más oscuro y sí se lee sobre blanco.
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colors.accentText),
      ),
      // Mantiene objetivos táctiles de al menos 48x48 dp (RNF-ACC-03).
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}
