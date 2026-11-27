import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/pixel_colors.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_tab.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Barra con las pestañas del detalle (Resumen, Evolución, Combate, Movs., Mapa).
class PokemonDetailTabBar extends StatelessWidget {
  const PokemonDetailTabBar({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final PokemonDetailTab selected;
  final ValueChanged<PokemonDetailTab> onSelected;

  /// Texto de cada pestaña según el idioma.
  String _label(AppLocalizations l10n, PokemonDetailTab tab) {
    return switch (tab) {
      PokemonDetailTab.summary => l10n.detailTabSummary,
      PokemonDetailTab.evolution => l10n.detailTabEvolution,
      PokemonDetailTab.combat => l10n.detailTabCombat,
      PokemonDetailTab.moves => l10n.detailTabMoves,
      PokemonDetailTab.map => l10n.detailTabMap,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.pixel;

    // Material (y no ColoredBox): las pestañas usan InkWell, que necesita un
    // Material debajo para pintar el toque. También tapa el contenido que
    // pasa por detrás cuando la barra está fija.
    return Material(
      color: colors.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colors.panelBorder, width: 3),
            ),
          ),
          child: Row(
            // stretch: cada pestaña ocupa todo el alto de la barra.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final tab in PokemonDetailTab.values)
                Expanded(
                  child: _TabButton(
                    label: _label(l10n, tab),
                    selected: tab == selected,
                    onTap: () => onSelected(tab),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.pixel;

    // El lector de pantalla dice "Resumen, botón, seleccionado". La selección
    // se comunica también con el fondo y la línea amarilla, no solo con color
    // de texto (RNF-ACC-05).
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? colors.panelHigh : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: selected ? colors.accent : Colors.transparent,
                width: 5,
              ),
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              // FittedBox: con texto muy grande, la etiqueta se encoge en vez
              // de desbordarse.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: selected ? colors.text : colors.textMuted,
                    fontVariations: const [FontVariation('wght', 700)],
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
