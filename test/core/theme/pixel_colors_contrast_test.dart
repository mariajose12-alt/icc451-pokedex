import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/theme/pixel_colors.dart';

/// Contraste WCAG entre dos colores: (más claro + 0.05) / (más oscuro + 0.05).
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  // RNF-ACC-02: 4.5:1 para texto normal (WCAG 2.1 AA).
  const minimum = 4.5;

  void checkTheme(String name, PixelColors c) {
    group('Contraste del tema $name', () {
      final pairs = <String, (Color, Color)>{
        'texto sobre fondo': (c.text, c.background),
        'texto sobre panel': (c.text, c.panel),
        'texto sobre panelHigh': (c.text, c.panelHigh),
        'secundario sobre fondo': (c.textMuted, c.background),
        'secundario sobre panel': (c.textMuted, c.panel),
        'secundario sobre panelHigh': (c.textMuted, c.panelHigh),
        'amarillo-texto sobre fondo': (c.accentText, c.background),
        'amarillo-texto sobre panel': (c.accentText, c.panel),
        'amarillo-texto sobre panelHigh': (c.accentText, c.panelHigh),
        'texto sobre amarillo': (c.onAccent, c.accent),
        'verde sobre panel': (c.success, c.panel),
        'verde sobre fondo': (c.success, c.background),
        'texto sobre carcasa': (c.onShell, c.shell),
        'texto sobre carcasa oscura': (c.onShell, c.shellDark),
        'texto sobre lente': (c.onAccent, c.lens),
      };

      pairs.forEach((label, pair) {
        test('$label ≥ 4.5:1', () {
          expect(_contrast(pair.$1, pair.$2), greaterThanOrEqualTo(minimum));
        });
      });
    });
  }

  checkTheme('oscuro', PixelColors.dark);
  checkTheme('claro', PixelColors.light);
}
