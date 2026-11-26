import 'package:flutter/material.dart';

import 'pixel_palette.dart';

/// Colores de la interfaz «Pokédex pixelada» en sus dos versiones, clara y
/// oscura. Los widgets los leen con `context.pixel`, así cambian solos cuando
/// cambia el tema.
@immutable
class PixelColors extends ThemeExtension<PixelColors> {
  const PixelColors({
    required this.background,
    required this.panel,
    required this.panelHigh,
    required this.panelBorder,
    required this.shadow,
    required this.shell,
    required this.shellDark,
    required this.onShell,
    required this.accent,
    required this.onAccent,
    required this.accentText,
    required this.lens,
    required this.success,
    required this.text,
    required this.textMuted,
  });

  /// Fondo de pantalla.
  final Color background;

  /// Tarjetas y barra de navegación.
  final Color panel;

  /// Botones inactivos.
  final Color panelHigh;

  /// Borde de las tarjetas.
  final Color panelBorder;

  /// Sombra dura de las tarjetas.
  final Color shadow;

  /// Carcasa roja de la Pokédex y su tono oscuro.
  final Color shell;
  final Color shellDark;

  /// Texto e iconos sobre la carcasa roja (siempre blanco).
  final Color onShell;

  /// Amarillo como relleno o borde: elemento activo y favoritos.
  final Color accent;

  /// Texto sobre el relleno amarillo.
  final Color onAccent;

  /// Amarillo cuando se usa como TEXTO o icono sobre un panel. En el tema
  /// claro es más oscuro, porque el amarillo puro no se lee sobre blanco.
  final Color accentText;

  /// Lente azul de la Pokédex.
  final Color lens;

  /// Verde: servicio disponible o respuesta correcta.
  final Color success;

  /// Texto principal y texto secundario.
  final Color text;
  final Color textMuted;

  /// Tema oscuro: son los colores que la app ya usaba.
  static const PixelColors dark = PixelColors(
    background: PixelPalette.background,
    panel: PixelPalette.panel,
    panelHigh: PixelPalette.panelHigh,
    panelBorder: PixelPalette.panelBorder,
    shadow: PixelPalette.shadow,
    shell: PixelPalette.shell,
    shellDark: PixelPalette.shellDark,
    onShell: Color(0xFFFFFFFF),
    accent: PixelPalette.accent,
    onAccent: PixelPalette.background,
    accentText: PixelPalette.accent,
    lens: PixelPalette.lens,
    success: PixelPalette.success,
    text: PixelPalette.text,
    textMuted: PixelPalette.textMuted,
  );

  /// Tema claro. Los pares de texto y fondo cumplen 4.5:1 (RNF-ACC-02); lo
  /// comprueba `pixel_colors_contrast_test.dart`.
  static const PixelColors light = PixelColors(
    background: Color(0xFFEEF1FA),
    panel: Color(0xFFFFFFFF),
    panelHigh: Color(0xFFDCE3F5),
    panelBorder: Color(0xFF3D4F8F),
    shadow: Color(0xFF9AA5C8),
    shell: Color(0xFFC83838),
    shellDark: Color(0xFF8A2424),
    onShell: Color(0xFFFFFFFF),
    accent: Color(0xFFF8C830),
    onAccent: Color(0xFF141A2E),
    accentText: Color(0xFF8A5A00),
    lens: Color(0xFF48A0F8),
    success: Color(0xFF1F7A2E),
    text: Color(0xFF141A2E),
    textMuted: Color(0xFF46507A),
  );

  @override
  PixelColors copyWith({
    Color? background,
    Color? panel,
    Color? panelHigh,
    Color? panelBorder,
    Color? shadow,
    Color? shell,
    Color? shellDark,
    Color? onShell,
    Color? accent,
    Color? onAccent,
    Color? accentText,
    Color? lens,
    Color? success,
    Color? text,
    Color? textMuted,
  }) {
    return PixelColors(
      background: background ?? this.background,
      panel: panel ?? this.panel,
      panelHigh: panelHigh ?? this.panelHigh,
      panelBorder: panelBorder ?? this.panelBorder,
      shadow: shadow ?? this.shadow,
      shell: shell ?? this.shell,
      shellDark: shellDark ?? this.shellDark,
      onShell: onShell ?? this.onShell,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accentText: accentText ?? this.accentText,
      lens: lens ?? this.lens,
      success: success ?? this.success,
      text: text ?? this.text,
      textMuted: textMuted ?? this.textMuted,
    );
  }

  /// Flutter la usa para animar el paso de un tema al otro.
  @override
  PixelColors lerp(ThemeExtension<PixelColors>? other, double t) {
    if (other is! PixelColors) {
      return this;
    }
    return PixelColors(
      background: Color.lerp(background, other.background, t)!,
      panel: Color.lerp(panel, other.panel, t)!,
      panelHigh: Color.lerp(panelHigh, other.panelHigh, t)!,
      panelBorder: Color.lerp(panelBorder, other.panelBorder, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      shell: Color.lerp(shell, other.shell, t)!,
      shellDark: Color.lerp(shellDark, other.shellDark, t)!,
      onShell: Color.lerp(onShell, other.onShell, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      accentText: Color.lerp(accentText, other.accentText, t)!,
      lens: Color.lerp(lens, other.lens, t)!,
      success: Color.lerp(success, other.success, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
    );
  }
}

/// Atajo para leer los colores del tema actual: `context.pixel.panel`.
/// Si el tema no trae [PixelColors] (por ejemplo, un widget de prueba dentro
/// de un `MaterialApp` simple), usa los oscuros, que son los de siempre.
extension PixelColorsContext on BuildContext {
  PixelColors get pixel =>
      Theme.of(this).extension<PixelColors>() ?? PixelColors.dark;
}
