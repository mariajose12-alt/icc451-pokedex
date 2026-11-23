import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';

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
    // El espacio extra a la derecha y abajo es para la sombra dura.
    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 4),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(color: PixelPalette.shadow, offset: Offset(4, 4)),
          ],
        ),
        child: Material(
          color: PixelPalette.panel,
          clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: PixelPalette.panelBorder, width: 3),
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
