import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pokedex/features/pokemon/domain/entities/game_region.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/game_region_art.dart';

/// Colores del escenario del mapa. Hay una versión oscura (la del mock: mar
/// nocturno con textos blancos) y una clara (mar celeste con textos oscuros),
/// para que en el tema claro el mapa no contraste tanto con el resto.
@immutable
class RegionMapColors {
  const RegionMapColors({
    required this.sea,
    required this.ray,
    required this.scanLine,
    required this.sparkle,
    required this.route,
    required this.islandShadow,
    required this.absent,
    required this.absentDot,
    required this.availableDot,
    required this.text,
    required this.textStroke,
    required this.selectedText,
    required this.generationText,
    required this.selection,
    required this.compassArm,
    required this.compassCenter,
    required this.compassNorth,
  });

  /// Degradado del mar, del centro al borde.
  final List<Color> sea;
  final Color ray;
  final Color scanLine;
  final Color sparkle;
  final Color route;
  final Color islandShadow;

  /// Islas donde el Pokémon no aparece y sus puntos de brillo.
  final Color absent;
  final Color absentDot;
  final Color availableDot;

  /// Nombre de la isla, su contorno, el de la isla elegida y «GEN …».
  final Color text;
  final Color textStroke;
  final Color selectedText;
  final Color generationText;

  /// Marco punteado de la isla elegida.
  final Color selection;
  final Color compassArm;
  final Color compassCenter;
  final Color compassNorth;

  static const RegionMapColors dark = RegionMapColors(
    sea: [
      Color(0xFF2F5FB8),
      Color(0xFF1F3F8C),
      Color(0xFF14275E),
      Color(0xFF0B1236),
    ],
    ray: Color(0x0DFFFFFF),
    scanLine: Color(0x1F000000),
    sparkle: Color(0x599FD8FF),
    route: Color(0x59FFFFFF),
    islandShadow: Color(0xCC0B0F1C),
    absent: Color(0xFF3A4468),
    absentDot: Color(0xFF4A5578),
    availableDot: Color(0x59FFFFFF),
    text: Color(0xFFFFFFFF),
    textStroke: Color(0xFF0B0F1C),
    selectedText: Color(0xFFF8C830),
    generationText: Color(0xFFC9D3EE),
    selection: Color(0xFFFFFFFF),
    compassArm: Color(0x99FFFFFF),
    compassCenter: Color(0xFF0B0F1C),
    compassNorth: Color(0xFFF8C830),
  );

  /// Tema claro: mar celeste que combina con el fondo de la app (#EEF1FA) y el
  /// azul del lente; textos oscuros con contorno blanco, como en el tema
  /// claro del resto de la interfaz.
  static const RegionMapColors light = RegionMapColors(
    sea: [
      Color(0xFFDCEBFC),
      Color(0xFFC4DBF6),
      Color(0xFFA9C8EE),
      Color(0xFF91B5E3),
    ],
    ray: Color(0x1AFFFFFF),
    scanLine: Color(0x0A1F3F8C),
    sparkle: Color(0xB3FFFFFF),
    route: Color(0x733D4F8F),
    islandShadow: Color(0x733D4F8F),
    absent: Color(0xFFC9D1E6),
    absentDot: Color(0xFFB1BBD6),
    availableDot: Color(0x66FFFFFF),
    text: Color(0xFF141A2E),
    textStroke: Color(0xFFFFFFFF),
    selectedText: Color(0xFF8A5A00),
    generationText: Color(0xFF46507A),
    selection: Color(0xFF3D4F8F),
    compassArm: Color(0x993D4F8F),
    compassCenter: Color(0xFF141A2E),
    compassNorth: Color(0xFF8A5A00),
  );
}

/// Dibuja el escenario del mapa (mar, islas, rutas, insignias y brújula).
///
/// Los colores del mar y los textos salen de [colors] (claro u oscuro). Los de
/// las islas con datos y las insignias ✓/✕ son iguales en los dos temas.
class RegionMapPainter extends CustomPainter {
  const RegionMapPainter({
    required this.available,
    required this.selected,
    required this.names,
    required this.textStyle,
    this.colors = RegionMapColors.dark,
  });

  /// Regiones donde aparece el Pokémon.
  final Set<GameRegion> available;
  final GameRegion selected;

  /// Nombre de cada región, ya en mayúsculas y en el idioma de la app.
  final Map<GameRegion, String> names;

  /// Solo aporta la tipografía.
  final TextStyle textStyle;

  /// Paleta del escenario según el tema.
  final RegionMapColors colors;

  static const Color _ink = Color(0xFF141A2E);
  static const Color _gold = Color(0xFFF8C830);

  @override
  void paint(Canvas canvas, Size size) {
    _paintSea(canvas, size);

    final scale = size.width / regionMapView.width;
    canvas
      ..save()
      ..scale(scale)
      ..translate(-regionMapView.left, -regionMapView.top);

    // Destellos y rutas.
    final sparkle = Paint()
      ..isAntiAlias = false
      ..color = colors.sparkle;
    for (final offset in regionSparkles) {
      canvas.drawRect(Rect.fromLTWH(offset.dx, offset.dy, 20, 3), sparkle);
    }
    final route = Paint()
      ..color = colors.route
      ..strokeWidth = 3;
    for (final (from, to) in regionRoutes) {
      _dashedLine(canvas, from, to, route, 6, 8);
    }

    // Marco de la región elegida (debajo de las insignias).
    _paintSelection(canvas, regionArt[selected]!.bounds.inflate(8));

    for (final region in GameRegion.values) {
      final art = regionArt[region]!;
      final isAvailable = available.contains(region);
      _paintIsland(canvas, art, isAvailable);
      _paintBadge(canvas, art.badge, isAvailable);
      _paintText(
        canvas,
        names[region] ?? region.name.toUpperCase(),
        art.label,
        12,
        region == selected ? colors.selectedText : colors.text,
      );
      _paintText(
        canvas,
        'GEN ${region.generation}',
        art.label.translate(0, 13),
        10,
        colors.generationText,
      );
    }

    _paintCompass(canvas);
    canvas.restore();
  }

  // Mar con rayos y líneas de pantalla, como el mock.
  void _paintSea(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.1),
          radius: 0.85,
          colors: colors.sea,
          stops: const [0, 0.4, 0.75, 1],
        ).createShader(rect),
    );

    final center = Offset(size.width / 2, size.height * 0.45);
    final ray = Paint()..color = colors.ray;
    final radius = size.longestSide * 1.5;
    for (var i = 0; i < 18; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        (i * 20 - 90) * math.pi / 180,
        8 * math.pi / 180,
        true,
        ray,
      );
    }

    final line = Paint()
      ..isAntiAlias = false
      ..color = colors.scanLine;
    for (var y = 0.0; y < size.height; y += 4) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 2), line);
    }
  }

  void _paintIsland(Canvas canvas, RegionArt art, bool isAvailable) {
    final shadow = Paint()
      ..isAntiAlias = false
      ..color = colors.islandShadow;
    final fill = Paint()
      ..isAntiAlias = false
      ..color = isAvailable ? art.color : colors.absent;
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _ink;
    final dot = Paint()
      ..isAntiAlias = false
      ..color = isAvailable ? colors.availableDot : colors.absentDot;

    Rect cellAt(int row, int column, [double shift = 0]) {
      return Rect.fromLTWH(
        art.origin.dx + column * RegionArt.cell + shift,
        art.origin.dy + row * RegionArt.cell + shift,
        RegionArt.cell,
        RegionArt.cell,
      );
    }

    // Primero la sombra dura de toda la isla y luego los cuadros.
    for (var row = 0; row < art.rows.length; row++) {
      for (var column = 0; column < art.rows[row].length; column++) {
        if (art.rows[row][column] != '.') {
          canvas.drawRect(cellAt(row, column, 4), shadow);
        }
      }
    }
    for (var row = 0; row < art.rows.length; row++) {
      for (var column = 0; column < art.rows[row].length; column++) {
        final kind = art.rows[row][column];
        if (kind == '.') continue;
        final rect = cellAt(row, column);
        canvas
          ..drawRect(rect, fill)
          ..drawRect(rect, edge);
        if (kind == 'o') {
          canvas.drawRect(
            Rect.fromLTWH(rect.left + 3, rect.top + 3, 4, 4),
            dot,
          );
        }
      }
    }
  }

  // ✓ verde si aparece, ✕ roja si no. Los símbolos se dibujan con líneas para
  // no depender de la tipografía.
  void _paintBadge(Canvas canvas, Offset origin, bool isAvailable) {
    final rect = Rect.fromLTWH(origin.dx, origin.dy, 22, 22);
    canvas
      ..drawRect(
        rect,
        Paint()
          ..isAntiAlias = false
          ..color = isAvailable
              ? const Color(0xFF5CD66C)
              : const Color(0xFFC83838),
      )
      ..drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = _ink,
      );

    final glyph = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.square
      ..color = isAvailable ? _ink : Colors.white;
    if (isAvailable) {
      final path = Path()
        ..moveTo(origin.dx + 6, origin.dy + 11.5)
        ..lineTo(origin.dx + 10, origin.dy + 15.5)
        ..lineTo(origin.dx + 16.5, origin.dy + 7);
      canvas.drawPath(path, glyph);
    } else {
      canvas
        ..drawLine(
          origin.translate(6.5, 6.5),
          origin.translate(15.5, 15.5),
          glyph,
        )
        ..drawLine(
          origin.translate(15.5, 6.5),
          origin.translate(6.5, 15.5),
          glyph,
        );
    }
  }

  void _paintSelection(Canvas canvas, Rect frame) {
    final dash = Paint()
      ..color = colors.selection
      ..strokeWidth = 3;
    _dashedLine(canvas, frame.topLeft, frame.topRight, dash, 7, 5);
    _dashedLine(canvas, frame.topRight, frame.bottomRight, dash, 7, 5);
    _dashedLine(canvas, frame.bottomRight, frame.bottomLeft, dash, 7, 5);
    _dashedLine(canvas, frame.bottomLeft, frame.topLeft, dash, 7, 5);

    final handle = Paint()
      ..isAntiAlias = false
      ..color = _gold;
    final handleEdge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _ink;
    for (final corner in [
      frame.topLeft,
      frame.topRight,
      frame.bottomLeft,
      frame.bottomRight,
    ]) {
      final square = Rect.fromCenter(center: corner, width: 8, height: 8);
      canvas
        ..drawRect(square, handle)
        ..drawRect(square, handleEdge);
    }
  }

  void _paintCompass(Canvas canvas) {
    const origin = Offset(346, 138);
    final arm = Paint()
      ..isAntiAlias = false
      ..color = colors.compassArm;
    final gold = Paint()
      ..isAntiAlias = false
      ..color = _gold;
    final center = Paint()
      ..isAntiAlias = false
      ..color = colors.compassCenter;

    Rect square(double x, double y) =>
        Rect.fromLTWH(origin.dx + x, origin.dy + y, 8, 8);
    canvas
      ..drawRect(square(8, 0), gold)
      ..drawRect(square(8, 16), arm)
      ..drawRect(square(0, 8), arm)
      ..drawRect(square(16, 8), arm)
      ..drawRect(square(8, 8), center);
    _paintText(canvas, 'N', origin.translate(12, -6), 11, colors.compassNorth);
  }

  // Texto centrado en [anchor] (línea base) con contorno para que se lea
  // sobre el mar y sobre las islas.
  void _paintText(
    Canvas canvas,
    String text,
    Offset anchor,
    double size,
    Color color,
  ) {
    TextStyle style() => TextStyle(
      fontFamily: textStyle.fontFamily,
      fontSize: size,
      fontWeight: FontWeight.w700,
      height: 1,
    );

    final stroke = TextPainter(
      text: TextSpan(
        text: text,
        style: style().copyWith(
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeJoin = StrokeJoin.round
            ..color = colors.textStroke,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final fill = TextPainter(
      text: TextSpan(
        text: text,
        style: style().copyWith(color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final baseline = fill.computeDistanceToActualBaseline(
      TextBaseline.alphabetic,
    );
    final offset = Offset(anchor.dx - fill.width / 2, anchor.dy - baseline);
    stroke.paint(canvas, offset);
    fill.paint(canvas, offset);
  }

  void _dashedLine(
    Canvas canvas,
    Offset from,
    Offset to,
    Paint paint,
    double dash,
    double gap,
  ) {
    final total = (to - from).distance;
    if (total == 0) return;
    final direction = (to - from) / total;
    var distance = 0.0;
    while (distance < total) {
      final end = math.min(distance + dash, total);
      canvas.drawLine(
        from + direction * distance,
        from + direction * end,
        paint,
      );
      distance += dash + gap;
    }
  }

  @override
  bool shouldRepaint(RegionMapPainter oldDelegate) {
    return oldDelegate.selected != selected ||
        oldDelegate.colors != colors ||
        oldDelegate.textStyle != textStyle ||
        oldDelegate.available.length != available.length ||
        !oldDelegate.available.containsAll(available) ||
        !_sameNames(oldDelegate.names);
  }

  bool _sameNames(Map<GameRegion, String> other) {
    for (final entry in names.entries) {
      if (other[entry.key] != entry.value) return false;
    }
    return other.length == names.length;
  }
}
