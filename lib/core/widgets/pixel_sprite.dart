import 'package:flutter/material.dart';

/// Un dibujo pixelado: una cuadrícula y los rectángulos que se pintan.
class PixelSpriteData {
  const PixelSpriteData({
    required this.columns,
    required this.rows,
    required this.rects,
    this.dimRects = const [],
  });

  /// Dibuja desde filas de texto: '#' = pixel pleno, '+' = pixel atenuado,
  /// cualquier otro carácter = vacío. Es más fácil de leer que los Rect.
  factory PixelSpriteData.fromRows(List<String> grid) {
    final solid = <Rect>[];
    final dim = <Rect>[];
    for (var y = 0; y < grid.length; y++) {
      for (var x = 0; x < grid[y].length; x++) {
        final cell = Rect.fromLTWH(x.toDouble(), y.toDouble(), 1, 1);
        if (grid[y][x] == '#') solid.add(cell);
        if (grid[y][x] == '+') dim.add(cell);
      }
    }
    return PixelSpriteData(
      columns: grid.first.length,
      rows: grid.length,
      rects: solid,
      dimRects: dim,
    );
  }

  final int columns;
  final int rows;

  /// Cada rectángulo es (x, y, ancho, alto) en la cuadrícula.
  final List<Rect> rects;

  /// Rectángulos que se pintan al 45 % (sombras o mitades apagadas).
  final List<Rect> dimRects;
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
  // Iconos de la barra inferior (los mismos del diseño).
  static final PixelSpriteData ball = PixelSpriteData.fromRows([
    '...#####...',
    '..#######..',
    '.#########.',
    '###########',
    '####...####',
    '....###....',
    '++++...++++',
    '+++++++++++',
    '.+++++++++.',
    '..+++++++..',
    '...+++++...',
  ]);

  static final PixelSpriteData heart = PixelSpriteData.fromRows([
    '...........',
    '..##...##..',
    '.#########.',
    '.#########.',
    '.#########.',
    '..#######..',
    '...#####...',
    '....###....',
    '.....#.....',
    '...........',
    '...........',
  ]);

  static final PixelSpriteData quiz = PixelSpriteData.fromRows([
    '...#####...',
    '..##...##..',
    '..##...##..',
    '.......##..',
    '......##...',
    '.....##....',
    '.....##....',
    '...........',
    '.....##....',
    '.....##....',
    '...........',
  ]);

  static final PixelSpriteData gear = PixelSpriteData.fromRows([
    '....###....',
    '.#..###..#.',
    '.#########.',
    '..###.###..',
    '####...####',
    '####...####',
    '####...####',
    '..###.###..',
    '.#########.',
    '.#..###..#.',
    '....###....',
  ]);
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
    // Celdas atenuadas: el mismo color al 45 % de opacidad.
    final dimPaint = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..isAntiAlias = false;
    for (final rect in sprite.dimRects) {
      canvas.drawRect(
        Rect.fromLTWH(
          rect.left * unit,
          rect.top * unit,
          rect.width * unit,
          rect.height * unit,
        ),
        dimPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_SpritePainter oldDelegate) =>
      oldDelegate.sprite != sprite || oldDelegate.color != color;
}
