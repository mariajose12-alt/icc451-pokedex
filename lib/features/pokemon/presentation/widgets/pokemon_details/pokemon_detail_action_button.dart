import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';

/// Botón de acción de la cabecera: 32 px visibles y 48 px tocables.
/// - [onPressed] null: botón desactivado.
/// - [selected] distinto de null: es un interruptor (shiny) y se ve amarillo
///   cuando está activo; el lector de pantalla dice «activado/desactivado».
/// - [showDot]: punto amarillo de aviso (hay otra forma elegida).
class PokemonDetailActionButton extends StatelessWidget {
  const PokemonDetailActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.selected,
    this.showDot = false,
    this.iconColor = Colors.white,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool? selected;
  final bool showDot;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final active = selected ?? false;
    final fill = active ? PixelPalette.accent : PixelPalette.background;
    final ink = active ? PixelPalette.background : iconColor;

    return Semantics(
      button: true,
      enabled: enabled,
      toggled: selected,
      label: label,
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: fill,
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
                      width: 32,
                      height: 32,
                      child: Icon(icon, size: 18, color: ink),
                    ),
                  ),
                  if (showDot)
                    Positioned(
                      top: -6,
                      right: -6,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: PixelPalette.accent,
                          border: Border.all(
                            color: PixelPalette.background,
                            width: 2,
                          ),
                        ),
                        child: const SizedBox(width: 12, height: 12),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
