import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';

/// Tarjeta del detalle: fondo azul claro y borde de 2 px.
class PokemonDetailCard extends StatelessWidget {
  const PokemonDetailCard({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: PixelPalette.panelHigh,
        border: Border.fromBorderSide(
          BorderSide(color: PixelPalette.panelBorder, width: 2),
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
