import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/pixel_colors.dart';

/// Insignia de texto sobre fondo amarillo: «Oculta», «Actual».
/// El significado va en la palabra, no solo en el color.
class PokemonDetailBadge extends StatelessWidget {
  const PokemonDetailBadge(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.pixel;

    return ColoredBox(
      color: colors.accent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        child: Text(
          label,
          // onAccent: texto oscuro sobre el amarillo en ambos temas.
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.onAccent,
            fontVariations: const [FontVariation('wght', 700)],
          ),
        ),
      ),
    );
  }
}
