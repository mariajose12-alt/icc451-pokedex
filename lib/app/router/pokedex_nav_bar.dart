import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';

/// Un destino de la barra: su icono normal, el activo y su nombre.
class PokedexNavItem {
  const PokedexNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Barra de navegación inferior con forma de carcasa de Pokédex:
/// mismo rojo que la banda de arriba y botones redondos.
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
    return Material(
      color: PixelPalette.shell,
      child: DecoratedBox(
        // Borde oscuro arriba: es el espejo del de la banda superior.
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: PixelPalette.shellDark, width: 4),
          ),
        ),
        // SafeArea respeta la barra de gestos del teléfono.
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
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
    );
  }
}

/// Un botón redondo con su etiqueta debajo.
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

    // Un solo bloque para el lector de pantalla: "Pokédex, botón, seleccionado".
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Activo: amarillo encendido. Inactivo: oscuro apagado.
                color: selected ? PixelPalette.accent : PixelPalette.shadow,
                border: Border.all(color: PixelPalette.shellDark, width: 3),
              ),
              child: Icon(
                selected ? item.selectedIcon : item.icon,
                size: 22,
                color: selected ? PixelPalette.shadow : PixelPalette.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelSmall?.copyWith(
                color: PixelPalette.text,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
