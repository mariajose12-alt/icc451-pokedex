import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';
import 'package:pokedex/features/favorites/presentation/cubit/favorite_cubit.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Botón de favorito sobre la esquina de la imagen (RF-DET-10, RF-COM-03).
/// Necesita un [FavoriteCubit] arriba en el árbol.
class PokemonDetailFavoriteButton extends StatelessWidget {
  const PokemonDetailFavoriteButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoriteCubit, bool>(
      builder: (context, isFavorite) => _HeartButton(
        isFavorite: isFavorite,
        onPressed: () => context.read<FavoriteCubit>().toggle(),
      ),
    );
  }
}

/// El corazón con su animación. Es StatefulWidget solo para el controlador
/// de la animación: es estado de interfaz.
class _HeartButton extends StatefulWidget {
  const _HeartButton({required this.isFavorite, required this.onPressed});

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  State<_HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<_HeartButton>
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
  void didUpdateWidget(_HeartButton oldWidget) {
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
    final l10n = AppLocalizations.of(context)!;
    final isFavorite = widget.isFavorite;
    final label = isFavorite
        ? l10n.detailFavoriteRemove
        : l10n.detailFavoriteAdd;
    final ink = isFavorite ? PixelPalette.background : Colors.white;

    return Semantics(
      button: true,
      toggled: isFavorite,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
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
                child: DecoratedBox(
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

/// Corazón pixelado: la misma cuadrícula de 9×8 del diseño.
class _PixelHeartPainter extends CustomPainter {
  const _PixelHeartPainter(this.color);

  final Color color;

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
    for (final rect in _rects) {
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
      oldDelegate.color != color;
}
