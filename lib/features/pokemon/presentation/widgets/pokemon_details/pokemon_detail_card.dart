import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/pixel_colors.dart';

/// Tarjeta del detalle: fondo resaltado y borde de 2 px.
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
    final colors = context.pixel;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.panelHigh,
        border: Border.fromBorderSide(
          BorderSide(color: colors.panelBorder, width: 2),
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
