import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/app_theme.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';

/// Ambiente del escenario. Cada pantalla de la trivia usa uno.
enum StageMood { warm, success, failure, gold, purple, dim }

class _StagePalette {
  const _StagePalette(
    this.colors, {
    this.rayOpacity = 0.17,
    this.scanOpacity = 0.10,
    this.confetti = false,
  });

  /// Del centro al borde.
  final List<Color> colors;
  final double rayOpacity;
  final double scanOpacity;
  final bool confetti;
}

const Map<StageMood, _StagePalette> _palettes = {
  StageMood.warm: _StagePalette([
    Color(0xFFFFE066),
    Color(0xFFF59A2C),
    Color(0xFFC23A5A),
    Color(0xFF2A1B5E),
  ]),
  StageMood.success: _StagePalette([
    Color(0xFFF1FF9A),
    Color(0xFF6FD060),
    Color(0xFF1E8A4A),
    Color(0xFF0E3B2E),
  ], confetti: true),
  StageMood.failure: _StagePalette([
    Color(0xFFFFB070),
    Color(0xFFE2502A),
    Color(0xFF8A1F3A),
    Color(0xFF2A0F2A),
  ], rayOpacity: 0.12),
  StageMood.gold: _StagePalette(
    [
      Color(0xFFFFF2A0),
      Color(0xFFFFC93A),
      Color(0xFFE0702A),
      Color(0xFF3A1B5E),
    ],
    rayOpacity: 0.2,
    confetti: true,
  ),
  StageMood.purple: _StagePalette([
    Color(0xFF8A7CFF),
    Color(0xFF5A3FB0),
    Color(0xFF2D2470),
    Color(0xFF141A2E),
  ], rayOpacity: 0.14),
  StageMood.dim: _StagePalette(
    [
      Color(0xFF7C8DBA),
      Color(0xFF3C4C8C),
      Color(0xFF232C55),
      Color(0xFF141A2E),
    ],
    rayOpacity: 0.07,
    scanOpacity: 0.16,
  ),
};

/// Fondo de escenario: degradado radial, rayos de luz, líneas de escaneo y
/// destellos. Lo que se pone encima ([child]) debe leerse sobre cualquier
/// color: por eso los textos importantes van en píldoras oscuras.
///
/// Hay dos formas de usarlo:
///  - `StageBackground(height: ...)`: altura fija (el contenido usa Stack).
///  - `StageBackground.grow(minHeight: ...)`: altura mínima; si el contenido
///    es más grande (texto del sistema al 200 %), el escenario crece.
class StageBackground extends StatelessWidget {
  const StageBackground({
    required this.mood,
    required double this.height,
    required this.child,
    super.key,
  }) : minHeight = null;

  const StageBackground.grow({
    required this.mood,
    required double this.minHeight,
    required this.child,
    super.key,
  }) : height = null;

  final StageMood mood;
  final double? height;
  final double? minHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // El escenario es una escena: siempre oscuro, sin importar el tema. Así los
    // textos blancos y las píldoras de encima se leen igual en claro y oscuro.
    final dark = AppTheme.dark;
    final content = Theme(
      data: dark,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: dark.colorScheme.onSurface),
        child: child,
      ),
    );

    // Se repinta solo si cambia el ambiente.
    final background = RepaintBoundary(
      child: CustomPaint(painter: _StagePainter(_palettes[mood]!)),
    );
    const border = BoxDecoration(
      border: Border(
        bottom: BorderSide(color: PixelPalette.background, width: 6),
      ),
    );

    final fixedHeight = height;
    if (fixedHeight != null) {
      return SizedBox(
        height: fixedHeight,
        child: DecoratedBox(
          decoration: border,
          child: ClipRect(
            child: Stack(fit: StackFit.expand, children: [background, content]),
          ),
        ),
      );
    }

    // Versión que crece: el contenido manda la altura; el fondo lo rellena.
    return DecoratedBox(
      decoration: border,
      child: ClipRect(
        child: Stack(
          children: [
            Positioned.fill(child: background),
            ConstrainedBox(
              // Ancho completo: sin esto la columna se encoge y queda a la izquierda.
              constraints: BoxConstraints(
                minWidth: double.infinity,
                minHeight: minHeight!,
              ),
              child: content,
            ),
          ],
        ),
      ),
    );
  }
}

class _StagePainter extends CustomPainter {
  const _StagePainter(this.palette);

  final _StagePalette palette;

  // (x, y, tamaño) como fracción del ancho y del alto.
  static const _sparkles = [
    (0.09, 0.42, 9.0),
    (0.83, 0.34, 7.0),
    (0.77, 0.76, 10.0),
    (0.13, 0.72, 6.0),
    (0.45, 0.28, 5.0),
  ];

  static const _confetti = [
    (0.06, 0.22, 9.0, Color(0xFFF8C830)),
    (0.92, 0.18, 8.0, Color(0xFFFF6FA8)),
    (0.20, 0.55, 7.0, Color(0xFF7DF3B0)),
    (0.88, 0.60, 8.0, Color(0xFFF8C830)),
    (0.60, 0.15, 6.0, Color(0xFF7DF3B0)),
    (0.35, 0.85, 7.0, Color(0xFFFF6FA8)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = Offset(size.width / 2, size.height * 0.57);

    // 1. Degradado del centro al borde.
    final gradient = RadialGradient(
      center: Alignment(0, center.dy / size.height * 2 - 1),
      radius: 1.0,
      colors: palette.colors,
      stops: const [0, 0.24, 0.56, 1],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    // 2. Rayos: cuñas de 8° cada 20°, desde el centro hacia afuera.
    final rays = Paint()
      ..color = Colors.white.withValues(alpha: palette.rayOpacity)
      ..isAntiAlias = false;
    final reach = size.longestSide * 1.5;
    const step = 20 * math.pi / 180;
    const wedge = 8 * math.pi / 180;
    for (var angle = 0.0; angle < 2 * math.pi; angle += step) {
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + reach * math.cos(angle),
          center.dy + reach * math.sin(angle),
        )
        ..lineTo(
          center.dx + reach * math.cos(angle + wedge),
          center.dy + reach * math.sin(angle + wedge),
        )
        ..close();
      canvas.drawPath(path, rays);
    }

    // 3. Líneas de escaneo: dan el aspecto de pantalla retro.
    final scan = Paint()
      ..color = Colors.black.withValues(alpha: palette.scanOpacity)
      ..isAntiAlias = false;
    for (var y = 0.0; y < size.height; y += 4) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 2), scan);
    }

    // 4. Destellos (rombos) y, en los ambientes festivos, confeti.
    final white = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..isAntiAlias = false;
    for (final (fx, fy, s) in _sparkles) {
      _diamond(canvas, Offset(size.width * fx, size.height * fy), s, white);
    }
    if (palette.confetti) {
      for (final (fx, fy, s, color) in _confetti) {
        _diamond(
          canvas,
          Offset(size.width * fx, size.height * fy),
          s,
          Paint()
            ..color = color
            ..isAntiAlias = false,
        );
      }
    }
  }

  void _diamond(Canvas canvas, Offset at, double size, Paint paint) {
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.rotate(math.pi / 4);
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: size, height: size),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_StagePainter oldDelegate) =>
      oldDelegate.palette != palette;
}
