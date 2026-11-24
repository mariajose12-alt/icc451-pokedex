import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';

/// Insignia de texto sobre fondo amarillo: «Oculta», «Actual».
/// El significado va en la palabra, no solo en el color.
class PokemonDetailBadge extends StatelessWidget {
  const PokemonDetailBadge(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: PixelPalette.accent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: PixelPalette.background,
            fontVariations: const [FontVariation('wght', 700)],
          ),
        ),
      ),
    );
  }
}
