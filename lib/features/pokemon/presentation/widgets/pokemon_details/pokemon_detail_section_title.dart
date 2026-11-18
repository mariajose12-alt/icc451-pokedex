import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';

/// Título de sección del detalle: cuadrito amarillo + texto en negrita.
class PokemonDetailSectionTitle extends StatelessWidget {
  const PokemonDetailSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      // header: el lector de pantalla puede saltar de título en título.
      child: Semantics(
        header: true,
        child: Row(
          children: [
            const SizedBox(
              width: 8,
              height: 8,
              child: ColoredBox(color: PixelPalette.accent),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontVariations: const [FontVariation('wght', 700)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
