import 'package:flutter/material.dart';

/// Un dibujo pixelado: una cuadrícula y los rectángulos que se pintan.
class PixelSpriteData {
  const PixelSpriteData({
    required this.columns,
    required this.rows,
    required this.rects,
  });

  final int columns;
  final int rows;

  /// Cada rectángulo es (x, y, ancho, alto) en la cuadrícula.
  final List<Rect> rects;
}

/// Los dibujos disponibles (los mismos del diseño).
abstract final class PixelSprites {
  static const PixelSpriteData cup = PixelSpriteData(
    columns: 9,
    rows: 8,
    rects: [
      Rect.fromLTWH(1, 0, 7, 4),
      Rect.fromLTWH(0, 1, 1, 2),
      Rect.fromLTWH(8, 1, 1, 2),
      Rect.fromLTWH(2, 4, 5, 1),
      Rect.fromLTWH(4, 5, 1, 2),
      Rect.fromLTWH(2, 7, 5, 1),
    ],
  );

  static const PixelSpriteData star = PixelSpriteData(
    columns: 9,
    rows: 8,
    rects: [
      Rect.fromLTWH(4, 0, 1, 2),
      Rect.fromLTWH(3, 2, 3, 1),
      Rect.fromLTWH(0, 3, 9, 1),
      Rect.fromLTWH(1, 4, 7, 1),
      Rect.fromLTWH(2, 5, 5, 1),
      Rect.fromLTWH(2, 6, 2, 1),
      Rect.fromLTWH(5, 6, 2, 1),
      Rect.fromLTWH(1, 7, 2, 1),
      Rect.fromLTWH(6, 7, 2, 1),
    ],
  );
}

/// Dibuja un [PixelSpriteData]. Es decorativo: no lo leen los lectores de
/// pantalla (el significado va en un texto al lado).
class PixelSprite extends StatelessWidget {
  const PixelSprite({
    required this.sprite,
    required this.color,
    this.width = 18,
    super.key,
  });

  final PixelSpriteData sprite;
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size(width, width * sprite.rows / sprite.columns),
        painter: _SpritePainter(sprite, color),
      ),
    );
  }
}

class _SpritePainter extends CustomPainter {
  const _SpritePainter(this.sprite, this.color);

  final PixelSpriteData sprite;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / sprite.columns;
    // Sin suavizado: los bordes del pixel quedan nítidos.
    final paint = Paint()
      ..color = color
      ..isAntiAlias = false;
    for (final rect in sprite.rects) {
      canvas.drawRect(
        Rect.fromLTWH(
          rect.left * unit,
          rect.top * unit,
          rect.width * unit,
          rect.height * unit,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SpritePainter oldDelegate) =>
      oldDelegate.sprite != sprite || oldDelegate.color != color;
}
