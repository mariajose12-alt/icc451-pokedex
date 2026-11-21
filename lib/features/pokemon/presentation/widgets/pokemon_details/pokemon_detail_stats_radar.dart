import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_stat.dart';

/// Gráfico de radar con los stats base. Es un resumen visual: los valores
/// exactos los muestra [PokemonDetailStats], por eso no se lee en voz alta.
class PokemonDetailStatsRadar extends StatelessWidget {
  const PokemonDetailStatsRadar({required this.stats, super.key});

  final List<PokemonStat> stats;

  /// Tamaño máximo del gráfico.
  static const double _maxSize = 220;

  @override
  Widget build(BuildContext context) {
    // Un polígono necesita al menos 3 vértices.
    if (stats.length < 3) {
      return const SizedBox.shrink();
    }

    // Se ordena por id para que los ejes siempre queden en el mismo orden:
    // HP, ataque, defensa, ataque esp., defensa esp., velocidad.
    final ordered = [...stats]..sort((a, b) => a.statId.compareTo(b.statId));
    final fractions = [for (final stat in ordered) stat.fraction];

    // Sin animación si el sistema las tiene desactivadas.
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 600);

    // El lector de pantalla se salta el radar: las barras dicen lo mismo.
    return ExcludeSemantics(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxSize),
          child: AspectRatio(
            aspectRatio: 1,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: duration,
              curve: Curves.easeOutCubic,
              builder: (context, progress, _) {
                return CustomPaint(
                  painter: _RadarPainter(
                    fractions: fractions,
                    progress: progress,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({required this.fractions, required this.progress});

  /// Valor de cada stat entre 0 y 1 (base / 255).
  final List<double> fractions;

  /// Avance de la animación, de 0 a 1.
  final double progress;

  /// Cuántos hexágonos concéntricos se dibujan de fondo.
  static const int _rings = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final count = fractions.length;
    final center = size.center(Offset.zero);
    // Se deja un margen para que los cuadritos de los vértices no se corten.
    final radius = math.min(size.width, size.height) / 2 - 6;

    // Posición del vértice [index] a la distancia [distance] del centro.
    // El primer eje apunta hacia arriba.
    Offset vertex(int index, double distance) {
      final angle = -math.pi / 2 + 2 * math.pi * index / count;
      return center + Offset(math.cos(angle), math.sin(angle)) * distance;
    }

    // Sin suavizado y con esquinas en ángulo: se ve pixelado como el resto.
    final gridPaint = Paint()
      ..isAntiAlias = false
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.miter
      ..color = PixelPalette.panelBorder;

    // Hexágonos de fondo; el exterior es más grueso.
    for (var ring = 1; ring <= _rings; ring++) {
      final ringRadius = radius * ring / _rings;
      final path = Path();
      for (var i = 0; i < count; i++) {
        final point = vertex(i, ringRadius);
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      gridPaint.strokeWidth = ring == _rings ? 3 : 1;
      canvas.drawPath(path, gridPaint);
    }

    // Ejes desde el centro hasta cada vértice exterior.
    gridPaint.strokeWidth = 1;
    for (var i = 0; i < count; i++) {
      canvas.drawLine(center, vertex(i, radius), gridPaint);
    }

    // Polígono de los stats. `progress` lo hace crecer desde el centro.
    final points = [
      for (var i = 0; i < count; i++)
        vertex(i, radius * fractions[i].clamp(0.0, 1.0) * progress),
    ];
    final shape = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      shape.lineTo(point.dx, point.dy);
    }
    shape.close();

    canvas.drawPath(
      shape,
      Paint()
        ..isAntiAlias = false
        ..style = PaintingStyle.fill
        ..color = PixelPalette.accent.withValues(alpha: 0.35),
    );
    canvas.drawPath(
      shape,
      Paint()
        ..isAntiAlias = false
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.miter
        ..color = PixelPalette.accent,
    );

    // Un cuadrito en cada vértice.
    final dotPaint = Paint()
      ..isAntiAlias = false
      ..color = PixelPalette.accent;
    for (final point in points) {
      canvas.drawRect(
        Rect.fromCenter(center: point, width: 7, height: 7),
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    // Solo se vuelve a dibujar si cambian los datos o la animación avanza.
    return oldDelegate.progress != progress ||
        oldDelegate.fractions != fractions;
  }
}
