import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/pixel_colors.dart';
import 'package:pokedex/core/widgets/pixel_sprite.dart';

/// Un destino de la barra: su dibujo pixelado y su nombre.
class PokedexNavItem {
  const PokedexNavItem({required this.sprite, required this.label});

  final PixelSpriteData sprite;
  final String label;
}

/// Barra de navegación inferior (diseño del mock, opción B): panel con
/// borde, sin fichas. La pestaña activa lleva un cursor amarillo arriba, fondo
/// resaltado y texto en negrita (no depende solo del color, IND-05).
class PokedexNavBar extends StatelessWidget {
  const PokedexNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<PokedexNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.pixel;

    return Material(
      color: colors.panel,
      child: DecoratedBox(
        // Borde arriba, separa la barra del contenido.
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.panelBorder, width: 4)),
        ),
        // SafeArea respeta la barra de gestos del teléfono.
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: _NavButton(
                        item: items[i],
                        selected: i == selectedIndex,
                        onTap: () => onSelected(i),
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

/// Una pestaña: icono pixelado y etiqueta siempre visible.
class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final PokedexNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.pixel;
    // Icono y texto: amarillo "de texto" si está activa, gris si no.
    final color = selected ? colors.accentText : colors.textMuted;

    // Un solo bloque para el lector de pantalla: "Pokédex, botón, seleccionado".
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        // Activo: fondo resaltado. Inactivo: transparente.
        color: selected ? colors.panelHigh : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            // 64 dp de alto: supera los 48 dp mínimos (RNF-ACC).
            constraints: const BoxConstraints(minHeight: 64),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Cursor amarillo arriba (solo en la pestaña activa).
                if (selected)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: FractionallySizedBox(
                        widthFactor: 0.56,
                        child: SizedBox(
                          height: 4,
                          child: ColoredBox(color: colors.accent),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PixelSprite(sprite: item.sprite, color: color, width: 22),
                      const SizedBox(height: 4),
                      // Sin límite de líneas: con texto al 200 % se parte
                      // y no se corta (RNF-ACC-04).
                      Text(
                        item.label,
                        textAlign: TextAlign.center,
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
