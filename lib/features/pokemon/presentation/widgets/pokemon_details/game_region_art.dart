import 'dart:ui';

import 'package:pokedex/features/pokemon/domain/entities/game_region.dart';

/// Dibujo de una isla del mapa. Todas las coordenadas están en las unidades
/// del mock (el mapa mide 390 de ancho).
class RegionArt {
  const RegionArt({
    required this.color,
    required this.origin,
    required this.rows,
    required this.label,
    required this.badge,
  });

  /// Lado de cada cuadro.
  static const double cell = 10;

  final Color color;

  /// Esquina superior izquierda de la cuadrícula.
  final Offset origin;
  final List<String> rows;

  /// Punto donde se centra el nombre (en la línea base del texto).
  final Offset label;

  /// Esquina superior izquierda de la insignia ✓/✕ (22 x 22).
  final Offset badge;

  /// Rectángulo que ocupa la cuadrícula.
  Rect get bounds => Rect.fromLTWH(
    origin.dx,
    origin.dy,
    rows.first.length * cell,
    rows.length * cell,
  );

  /// Zona que se puede tocar: isla, nombre e insignia.
  Rect get touchArea => bounds
      .expandToInclude(Rect.fromLTWH(label.dx - 36, label.dy - 12, 72, 28))
      .expandToInclude(Rect.fromLTWH(badge.dx, badge.dy, 22, 22))
      .inflate(2);
}

/// Parte del mapa que se ve: se recorta lo que sobra arriba y abajo.
const Rect regionMapView = Rect.fromLTWH(0, 30, 390, 372);

/// Las nueve islas.
const Map<GameRegion, RegionArt> regionArt = {
  GameRegion.kanto: RegionArt(
    color: Color(0xFFF8C830),
    origin: Offset(130, 170),
    rows: [
      '..###o##..',
      '.##o####o.',
      '#o####o###',
      '####o####o',
      '##o####o##',
      '.####o###.',
      '..#o####..',
    ],
    label: Offset(180, 264),
    badge: Offset(222, 160),
  ),
  GameRegion.johto: RegionArt(
    color: Color(0xFF7DF3B0),
    origin: Offset(10, 180),
    rows: ['.####o.', '###o###', '#o####o', '.###o##', '..o####', '...##o.'],
    label: Offset(45, 256),
    badge: Offset(72, 170),
  ),
  GameRegion.hoenn: RegionArt(
    color: Color(0xFFFF9A5C),
    origin: Offset(30, 310),
    rows: [
      '..###o..',
      '.##o###.',
      '#o####o#',
      '####o###',
      '.#o####o',
      '..###o..',
    ],
    label: Offset(70, 386),
    badge: Offset(102, 300),
  ),
  GameRegion.sinnoh: RegionArt(
    color: Color(0xFF7FD4FF),
    origin: Offset(150, 40),
    rows: [
      '...##...',
      '..#o##..',
      '.o####o.',
      '####o###',
      '.#o####.',
      '..###o..',
    ],
    label: Offset(190, 116),
    badge: Offset(222, 30),
  ),
  GameRegion.unova: RegionArt(
    color: Color(0xFFE6E6FF),
    origin: Offset(280, 180),
    rows: ['..o#o#.', '#o#o#o#', 'o#o#o#o', '#o#o#o#', '.#o#o#o', '..#o#o.'],
    label: Offset(315, 256),
    badge: Offset(342, 170),
  ),
  GameRegion.kalos: RegionArt(
    color: Color(0xFFFF8FB8),
    origin: Offset(280, 50),
    rows: ['..###o.', '.##o###', '#o####o', '####o##', '.#o###.', '..###..'],
    label: Offset(315, 126),
    badge: Offset(342, 40),
  ),
  GameRegion.alola: RegionArt(
    color: Color(0xFF5CD6C8),
    origin: Offset(280, 310),
    rows: [
      'o#...o#.',
      '##..####',
      '.....#o#',
      '..##..#.',
      '.#o##...',
      '..##....',
    ],
    label: Offset(320, 386),
    badge: Offset(352, 300),
  ),
  GameRegion.galar: RegionArt(
    color: Color(0xFF8E7CFF),
    origin: Offset(20, 50),
    rows: ['..###..', '###o###', '.o####o', '####o##', '..o###.'],
    label: Offset(55, 116),
    badge: Offset(82, 40),
  ),
  GameRegion.paldea: RegionArt(
    color: Color(0xFFB8E04C),
    origin: Offset(160, 310),
    rows: [
      '..o#o#o.',
      '.o#o#o#o',
      'o#o#o#o#',
      '#o#o#o#o',
      '.#o#o#o.',
      '..#o#o..',
    ],
    label: Offset(200, 386),
    badge: Offset(232, 300),
  ),
};

/// Rutas punteadas entre islas.
const List<(Offset, Offset)> regionRoutes = [
  (Offset(70, 110), Offset(150, 110)),
  (Offset(230, 110), Offset(290, 110)),
  (Offset(60, 240), Offset(130, 230)),
  (Offset(240, 230), Offset(290, 240)),
  (Offset(80, 360), Offset(160, 360)),
  (Offset(230, 360), Offset(300, 360)),
  (Offset(180, 130), Offset(180, 170)),
  (Offset(180, 250), Offset(180, 310)),
];

/// Destellos sobre el agua (rectángulos de 20 x 3).
const List<Offset> regionSparkles = [
  Offset(80, 20),
  Offset(90, 23),
  Offset(240, 30),
  Offset(250, 33),
  Offset(360, 140),
  Offset(370, 143),
  Offset(100, 150),
  Offset(110, 153),
  Offset(260, 150),
  Offset(270, 153),
  Offset(70, 280),
  Offset(80, 283),
  Offset(340, 280),
  Offset(350, 283),
  Offset(230, 280),
  Offset(240, 283),
  Offset(110, 400),
  Offset(120, 403),
  Offset(270, 400),
  Offset(280, 403),
  Offset(20, 380),
  Offset(30, 383),
  Offset(350, 380),
  Offset(360, 383),
];
