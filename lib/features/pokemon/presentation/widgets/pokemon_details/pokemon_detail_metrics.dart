import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pokedex/core/theme/pixel_colors.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Altura y peso del Pokémon (RF-DET-07).
/// PokeAPI da la altura en decímetros y el peso en hectogramos: dividir entre
/// 10 da metros y kilogramos.
class PokemonDetailMetrics extends StatelessWidget {
  const PokemonDetailMetrics({
    required this.heightDecimeters,
    required this.weightHectograms,
    super.key,
  });

  final int heightDecimeters;
  final int weightHectograms;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Un decimal, con la coma o el punto que corresponda al idioma.
    final format = NumberFormat(
      '0.0',
      Localizations.localeOf(context).toString(),
    );

    // En la base el dato es opcional y la entidad lo guarda como 0 si falta:
    // se muestra "—" en vez de "0 m".
    final heightText = heightDecimeters <= 0
        ? '—'
        : l10n.detailHeightValue(format.format(heightDecimeters / 10));
    final weightText = weightHectograms <= 0
        ? '—'
        : l10n.detailWeightValue(format.format(weightHectograms / 10));

    final heightTile = _MetricTile(
      icon: Icons.height,
      label: l10n.detailHeight,
      value: heightText,
    );
    final weightTile = _MetricTile(
      icon: Icons.monitor_weight_outlined,
      label: l10n.detailWeight,
      value: weightText,
    );

    // Con texto muy grande, una casilla debajo de la otra.
    final stacked = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [heightTile, const SizedBox(height: 8), weightTile],
      );
    }

    return Row(
      children: [
        Expanded(child: heightTile),
        const SizedBox(width: 8),
        Expanded(child: weightTile),
      ],
    );
  }
}

/// Casilla con icono, etiqueta y valor.
class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.pixel;

    // MergeSemantics: el lector de pantalla dice "Altura, 0,7 m" de una vez.
    return MergeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.panelHigh,
          border: Border.all(color: colors.panelBorder, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      value,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontVariations: const [FontVariation('wght', 700)],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
