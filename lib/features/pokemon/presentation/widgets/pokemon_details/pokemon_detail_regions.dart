import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/core/theme/pixel_colors.dart';
import 'package:pokedex/core/widgets/pixel_panel.dart';
import 'package:pokedex/features/pokemon/domain/entities/game_region.dart';
import 'package:pokedex/features/pokemon/domain/entities/move_version_group.dart';
import 'package:pokedex/features/pokemon/domain/usecases/group_version_groups_by_region.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_moves_cubit.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_moves_state.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/game_names.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/game_region_art.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_extras_pending.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/region_map_painter.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Pestaña Mapa (RF-COM-07, acceso de RF-DET-10): escenario ilustrado con las
/// nueve regiones y, debajo, los juegos de la que se toca. Lee las versiones
/// que ya guarda [PokemonMovesCubit] (base local), sin consultas nuevas.
class PokemonDetailRegions extends StatefulWidget {
  const PokemonDetailRegions({super.key});

  @override
  State<PokemonDetailRegions> createState() => _PokemonDetailRegionsState();
}

class _PokemonDetailRegionsState extends State<PokemonDetailRegions> {
  // Isla tocada. Es estado de interfaz: no se guarda. Si es null se muestra
  // la primera región con datos.
  GameRegion? _selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.pixel;
    final textTheme = Theme.of(context).textTheme;
    final languageCode = Localizations.localeOf(context).languageCode;

    return BlocBuilder<PokemonMovesCubit, PokemonMovesState>(
      builder: (context, state) {
        // Sin versiones: todavía no se descargó el detalle.
        if (state.versionGroups.isEmpty) {
          return const PokemonDetailExtrasPending();
        }

        final byRegion = groupVersionGroupsByRegion(state.versionGroups);
        if (byRegion.isEmpty) {
          return Text(
            l10n.regionsEmpty,
            style: textTheme.bodyMedium?.copyWith(color: colors.textMuted),
          );
        }

        final selected = _selected ?? byRegion.keys.first;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _RegionStage(
              byRegion: byRegion,
              selected: selected,
              onSelected: (region) => setState(() => _selected = region),
            ),
            const SizedBox(height: 12),
            _RegionPanel(
              region: selected,
              games: byRegion[selected] ?? const <MoveVersionGroup>[],
              languageCode: languageCode,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.regionsDisclaimer,
              style: textTheme.bodySmall?.copyWith(color: colors.textMuted),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Escenario
// ---------------------------------------------------------------------------

class _RegionStage extends StatelessWidget {
  const _RegionStage({
    required this.byRegion,
    required this.selected,
    required this.onSelected,
  });

  final Map<GameRegion, List<MoveVersionGroup>> byRegion;
  final GameRegion selected;
  final ValueChanged<GameRegion> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.pixel;
    final names = {
      for (final region in GameRegion.values)
        region: gameRegionName(l10n, region).toUpperCase(),
    };
    final textStyle =
        Theme.of(context).textTheme.labelSmall ?? const TextStyle();

    // El lector de pantalla oye el resumen y luego cada isla como botón.
    return Semantics(
      container: true,
      label: l10n.regionsMapLabel(byRegion.length, GameRegion.values.length),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colors.panelBorder, width: 3),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final scale = width / regionMapView.width;
            final height = regionMapView.height * scale;

            return SizedBox(
              width: width,
              height: height,
              child: Stack(
                children: [
                  // El dibujo es decorativo: el significado va en las islas
                  // de abajo (botones con etiqueta).
                  ExcludeSemantics(
                    child: CustomPaint(
                      size: Size(width, height),
                      painter: RegionMapPainter(
                        available: byRegion.keys.toSet(),
                        selected: selected,
                        names: names,
                        textStyle: textStyle,
                      ),
                    ),
                  ),
                  for (final region in GameRegion.values)
                    Positioned.fromRect(
                      rect: _toWidget(regionArt[region]!.touchArea, scale),
                      child: _RegionTile(
                        key: ValueKey('region-${region.name}'),
                        label: (byRegion[region]?.length ?? 0) > 0
                            ? l10n.regionAvailable(
                                byRegion[region]!.length,
                                gameRegionName(l10n, region),
                              )
                            : l10n.regionUnavailable(
                                gameRegionName(l10n, region),
                              ),
                        selected: region == selected,
                        onTap: () => onSelected(region),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // De unidades del mock a píxeles de pantalla.
  Rect _toWidget(Rect area, double scale) {
    return Rect.fromLTRB(
      (area.left - regionMapView.left) * scale,
      (area.top - regionMapView.top) * scale,
      (area.right - regionMapView.left) * scale,
      (area.bottom - regionMapView.top) * scale,
    );
  }
}

/// Zona tocable (transparente) sobre una isla.
class _RegionTile extends StatelessWidget {
  const _RegionTile({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(onTap: onTap),
    );
  }
}

// ---------------------------------------------------------------------------
// Panel de juegos
// ---------------------------------------------------------------------------

class _RegionPanel extends StatelessWidget {
  const _RegionPanel({
    required this.region,
    required this.games,
    required this.languageCode,
  });

  final GameRegion region;
  final List<MoveVersionGroup> games;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.pixel;
    final textTheme = Theme.of(context).textTheme;
    final name = gameRegionName(l10n, region);

    // liveRegion: al tocar otra isla el lector de pantalla anuncia el cambio.
    return Semantics(
      liveRegion: true,
      child: PixelPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.regionPanelLabel(name.toUpperCase(), region.generation),
              style: textTheme.labelMedium?.copyWith(
                color: colors.textMuted,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 2),
            if (games.isEmpty)
              Text(
                l10n.regionsNoGames(name),
                style: textTheme.bodyMedium?.copyWith(color: colors.textMuted),
              )
            else ...[
              Text(
                l10n.regionEntregas(games.length),
                style: textTheme.titleLarge?.copyWith(
                  color: colors.text,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final game in games)
                    _GameChip(label: versionGroupName(game.name, languageCode)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                l10n.regionStarters(region.starters.join(' · ')),
                style: textTheme.bodySmall?.copyWith(color: colors.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GameChip extends StatelessWidget {
  const _GameChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.pixel;

    // La marca ✓ y el borde verde dicen «aparece»; el texto dice cuál juego.
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colors.success, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 14, color: colors.success),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: colors.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
