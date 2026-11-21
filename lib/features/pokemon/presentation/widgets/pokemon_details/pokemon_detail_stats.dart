import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_stat.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Sección de estadísticas base del detalle (RF-DET-02): una barra por stat,
/// con valor y porcentaje, y el total debajo.
class PokemonDetailStats extends StatelessWidget {
  const PokemonDetailStats({
    required this.stats,
    required this.total,
    super.key,
  });

  /// Stats ordenados por statId (1 a 6), como los entrega el repositorio.
  final List<PokemonStat> stats;

  /// Suma de los stats base (Pokemon.totalStats).
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.detailStatsTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontVariations: const [FontVariation('wght', 700)],
          ),
        ),
        const SizedBox(height: 8),
        // Sin stats guardados: mensaje en vez de barras vacías.
        if (stats.isEmpty)
          Text(
            l10n.detailStatsEmpty,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else ...[
          for (final stat in stats) _StatRow(stat: stat),
          const SizedBox(height: 8),
          _TotalRow(total: total),
        ],
      ],
    );
  }
}

/// Nombre visible de cada stat según su id (1 a 6). Está aquí y no en el
/// dominio porque depende del idioma.
String _statName(AppLocalizations l10n, int statId) {
  return switch (statId) {
    1 => l10n.statHp,
    2 => l10n.statAttack,
    3 => l10n.statDefense,
    4 => l10n.statSpAttack,
    5 => l10n.statSpDefense,
    6 => l10n.statSpeed,
    // Un id desconocido no debe romper la pantalla.
    _ => '#$statId',
  };
}

/// Color de la barra según el valor. Es solo refuerzo visual: el valor y el
/// porcentaje también están en texto (RNF-ACC-05).
Color _barColor(int baseStat) {
  if (baseStat < 50) {
    return PixelPalette.shell;
  }
  if (baseStat < 100) {
    return PixelPalette.accent;
  }
  if (baseStat < 150) {
    return PixelPalette.success;
  }
  return PixelPalette.lens;
}

/// Una fila: nombre, valor y porcentaje arriba; la barra debajo.
class _StatRow extends StatelessWidget {
  const _StatRow({required this.stat});

  final PokemonStat stat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final name = _statName(l10n, stat.statId);

    // Un solo bloque para el lector de pantalla: "Ataque: 84, 33 por ciento".
    return Semantics(
      container: true,
      label: l10n.detailStatSemantic(name, stat.baseStat, stat.percent),
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                // Expanded: si el nombre es largo, baja de línea en vez de
                // desbordar (texto del sistema al 200 %).
                Expanded(
                  child: Text(
                    name,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  '${stat.baseStat}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontVariations: const [FontVariation('wght', 700)],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.detailStatPercent(stat.percent),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _StatBar(fraction: stat.fraction, color: _barColor(stat.baseStat)),
          ],
        ),
      ),
    );
  }
}

/// Barra pixelada: fondo oscuro con borde y un bloque de color encima.
/// Crece desde 0 hasta su valor al aparecer.
class _StatBar extends StatelessWidget {
  const _StatBar({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Si el sistema pide menos animaciones, la barra aparece ya llena.
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 600);

    return SizedBox(
      height: 14,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: PixelPalette.shadow,
          border: Border.all(color: PixelPalette.panelBorder, width: 2),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          // TweenAnimationBuilder anima de 0 a [fraction] sin controlador.
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: fraction),
            duration: duration,
            curve: Curves.easeOut,
            builder: (context, value, _) {
              return FractionallySizedBox(
                widthFactor: value,
                heightFactor: 1,
                child: ColoredBox(color: color),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Fila del total: etiqueta a la izquierda y la suma a la derecha.
class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // MergeSemantics: el lector dice "Total, 534" de una vez.
    return MergeSemantics(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: PixelPalette.panelBorder, width: 2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.detailStatTotal,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontVariations: const [FontVariation('wght', 700)],
                  ),
                ),
              ),
              Text(
                '$total',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: PixelPalette.accent,
                  fontVariations: const [FontVariation('wght', 700)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
