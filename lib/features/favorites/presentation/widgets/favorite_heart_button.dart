import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';
import 'package:pokedex/core/theme/pixel_colors.dart';

/// Botón de corazón de favorito (RF-COM-03). No sabe de bases de datos:
/// recibe si es favorito, la etiqueta y qué hacer al tocarlo.
class FavoriteHeartButton extends StatefulWidget {
  const FavoriteHeartButton({
    required this.isFavorite,
    required this.label,
    required this.onPressed,
    this.bare = false,
    super.key,
  });

  /// true: corazón suelto, sin recuadro (tarjetas del catálogo).
  /// false: con recuadro (encabezado del detalle).
  final bool bare;

  final bool isFavorite;

  /// Texto para lectores de pantalla y tooltip. Cambia según el estado.
  final String label;
  final VoidCallback onPressed;

  @override
  State<FavoriteHeartButton> createState() => _FavoriteHeartButtonState();
}

class _FavoriteHeartButtonState extends State<FavoriteHeartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  late Animation<double> _scale = _pop(grow: true);

  // Al agregar, el corazón crece y se asienta con rebote. Al quitar, se
  // encoge un poco y vuelve.
  Animation<double> _pop({required bool grow}) {
    final peak = grow ? 1.35 : 0.8;
    return TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: peak,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: peak,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(FavoriteHeartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite == widget.isFavorite) {
      return;
    }
    // Con «reducir animaciones» activado, el cambio es instantáneo.
    if (MediaQuery.disableAnimationsOf(context)) {
      return;
    }
    _scale = _pop(grow: widget.isFavorite);
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = widget.isFavorite;
    final ink = isFavorite ? PixelPalette.background : Colors.white;

    // Corazón suelto: relleno y rojo si es favorito; solo el contorno, en gris,
    // si no. Cambia la forma además del color (RNF-ACC-05).
    final Widget bareHeart = CustomPaint(
      size: const Size(27, 24),
      painter: _PixelHeartPainter(
        isFavorite ? _favoriteRed(context) : context.pixel.textMuted,
        outline: !isFavorite,
      ),
    );

    return Semantics(
      button: true,
      toggled: isFavorite,
      label: widget.label,
      excludeSemantics: true,
      // Con excludeSemantics el toque del InkWell se oculta: se repite aquí.
      onTap: widget.onPressed,
      child: Tooltip(
        message: widget.label,
        excludeFromSemantics: true,
        child: InkWell(
          onTap: widget.onPressed,
          // 48 px tocables; el cuadro visible mide 40.
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: ScaleTransition(
                scale: _scale,
                child: widget.bare
                    ? bareHeart
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          color: isFavorite
                              ? PixelPalette.accent
                              : PixelPalette.background,
                          border: Border.all(
                            color: PixelPalette.background,
                            width: 3,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: PixelPalette.shadow,
                              offset: Offset(3, 3),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(
                            child: CustomPaint(
                              size: const Size(18, 16),
                              painter: _PixelHeartPainter(ink),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rojo del corazón favorito, con contraste suficiente en cada tema.
Color _favoriteRed(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFFF6B6B)
      : const Color(0xFFC83838);
}

class _PixelHeartPainter extends CustomPainter {
  const _PixelHeartPainter(this.color, {this.outline = false});

  final Color color;

  /// true: solo el contorno (corazón vacío).
  final bool outline;

  // Contorno: el mismo corazón sin el interior.
  static const _outlineRects = <Rect>[
    Rect.fromLTWH(1, 0, 2, 1),
    Rect.fromLTWH(6, 0, 2, 1),
    Rect.fromLTWH(0, 1, 1, 1),
    Rect.fromLTWH(3, 1, 1, 1),
    Rect.fromLTWH(5, 1, 1, 1),
    Rect.fromLTWH(8, 1, 1, 1),
    Rect.fromLTWH(0, 2, 1, 2),
    Rect.fromLTWH(8, 2, 1, 2),
    Rect.fromLTWH(1, 4, 1, 1),
    Rect.fromLTWH(7, 4, 1, 1),
    Rect.fromLTWH(2, 5, 1, 1),
    Rect.fromLTWH(6, 5, 1, 1),
    Rect.fromLTWH(3, 6, 1, 1),
    Rect.fromLTWH(5, 6, 1, 1),
    Rect.fromLTWH(4, 7, 1, 1),
  ];

  // Cada rectángulo es (x, y, ancho, alto) en la cuadrícula de 9×8.
  static const _rects = <Rect>[
    Rect.fromLTWH(1, 0, 2, 1),
    Rect.fromLTWH(6, 0, 2, 1),
    Rect.fromLTWH(0, 1, 4, 1),
    Rect.fromLTWH(5, 1, 4, 1),
    Rect.fromLTWH(0, 2, 9, 1),
    Rect.fromLTWH(0, 3, 9, 1),
    Rect.fromLTWH(1, 4, 7, 1),
    Rect.fromLTWH(2, 5, 5, 1),
    Rect.fromLTWH(3, 6, 3, 1),
    Rect.fromLTWH(4, 7, 1, 1),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 9;
    // Sin suavizado: los bordes del pixel quedan nítidos.
    final paint = Paint()
      ..color = color
      ..isAntiAlias = false;
    for (final rect in outline ? _outlineRects : _rects) {
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
  bool shouldRepaint(_PixelHeartPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.outline != outline;
}
