import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';

enum TriviaButtonKind { primary, secondary }

/// Botón pixelado de la trivia: borde grueso y sombra dura.
/// Si [onPressed] es null se ve y se lee como desactivado.
class TriviaButton extends StatelessWidget {
  const TriviaButton({
    required this.label,
    required this.onPressed,
    this.kind = TriviaButtonKind.primary,
    this.height = 52,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final TriviaButtonKind kind;

  /// Altura mínima. Nunca menor de 48 (RNF-ACC-03); crece con el texto.
  final double height;

  @override
  Widget build(BuildContext context) {
    final primary = kind == TriviaButtonKind.primary;
    final textColor = primary ? PixelPalette.background : PixelPalette.text;

    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: Padding(
        // Espacio para la sombra dura, igual que PixelPanel.
        padding: const EdgeInsets.only(right: 4, bottom: 4),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(color: PixelPalette.shadow, offset: Offset(4, 4)),
            ],
          ),
          child: Material(
            color: primary ? PixelPalette.accent : PixelPalette.panelHigh,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: primary
                    ? PixelPalette.background
                    : PixelPalette.panelBorder,
                width: 3,
              ),
            ),
            child: InkWell(
              onTap: onPressed,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: height),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontVariations: const [FontVariation('wght', 700)],
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
