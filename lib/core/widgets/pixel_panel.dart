import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/pixel_colors.dart';

/// Panel con aspecto pixelado: esquinas rectas, borde grueso y sombra dura
/// desplazada (sin desenfoque), como las ventanas de un juego retro.
class PixelPanel extends StatelessWidget {
  const PixelPanel({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(12),
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    // Los colores salen del tema actual (claro u oscuro).
    final colors = context.pixel;

    // El espacio extra a la derecha y abajo es para la sombra dura.
    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: colors.shadow, offset: const Offset(4, 4)),
          ],
        ),
        child: Material(
          color: colors.panel,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: colors.panelBorder, width: 3),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
