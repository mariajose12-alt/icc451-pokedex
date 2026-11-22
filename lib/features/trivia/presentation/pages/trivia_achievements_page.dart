import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';
import 'package:pokedex/core/widgets/pixel_sprite.dart';
import 'package:pokedex/features/trivia/presentation/models/trivia_view_data.dart';
import 'package:pokedex/features/trivia/presentation/widgets/stage_background.dart';
import 'package:pokedex/features/trivia/presentation/widgets/trivia_button.dart';
import 'package:pokedex/features/trivia/presentation/widgets/trivia_parts.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Logros (RF-TRV-04): cabecera con el avance y una cuadrícula de tarjetas.
class TriviaAchievementsPage extends StatelessWidget {
  const TriviaAchievementsPage({
    required this.achievements,
    required this.onBack,
    super.key,
  });

  final List<TriviaAchievementData> achievements;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final unlocked = achievements.where((a) => a.unlocked).length;

    // Con texto muy grande las tarjetas pasan a una sola columna.
    final columns = MediaQuery.textScalerOf(context).scale(1) > 1.4 ? 1 : 2;

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StageBackground.grow(
                  mood: StageMood.gold,
                  minHeight: 260,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                        child: Column(
                          children: [
                            const PixelSprite(
                              sprite: PixelSprites.cup,
                              color: PixelPalette.background,
                              width: 64,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              l10n.triviaAchievements,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontSize: 30,
                                color: Colors.white,
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                shadows: const [
                                  Shadow(
                                    color: PixelPalette.background,
                                    offset: Offset(3, 3),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      StageStrip(
                        child: Semantics(
                          label: l10n.triviaUnlockedOf(
                            unlocked,
                            achievements.length,
                          ),
                          excludeSemantics: true,
                          child: Row(
                            children: [
                              Text(
                                l10n.triviaCorrectOf(
                                  unlocked,
                                  achievements.length,
                                ),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontVariations: const [
                                    FontVariation('wght', 700),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SegmentedBar(
                                  filled: unlocked,
                                  total: achievements.length,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Filas de [columns] tarjetas. IntrinsicHeight hace que
                      // las dos de una fila midan lo mismo.
                      for (
                        var i = 0;
                        i < achievements.length;
                        i += columns
                      ) ...[
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (
                                var j = i;
                                j < i + columns && j < achievements.length;
                                j++
                              ) ...[
                                if (j > i) const SizedBox(width: 10),
                                Expanded(
                                  child: _AchievementTile(
                                    data: achievements[j],
                                  ),
                                ),
                              ],
                              // Si la última fila queda impar, deja el hueco.
                              if (i + columns > achievements.length &&
                                  columns == 2) ...[
                                const SizedBox(width: 10),
                                const Expanded(child: SizedBox.shrink()),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 6),
                      TriviaButton(
                        label: l10n.triviaBack,
                        kind: TriviaButtonKind.secondary,
                        height: 48,
                        onPressed: onBack,
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

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.data});

  final TriviaAchievementData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final unlocked = data.unlocked;

    // Una sola lectura por tarjeta: nombre, descripción y estado.
    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: unlocked ? PixelPalette.panelHigh : PixelPalette.panel,
          border: Border.all(
            color: unlocked ? PixelPalette.accent : PixelPalette.panelBorder,
            width: 3,
          ),
          boxShadow: const [
            BoxShadow(color: PixelPalette.shadow, offset: Offset(4, 4)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ExcludeSemantics(
                    child: PixelSprite(
                      sprite: PixelSprites.star,
                      color: unlocked
                          ? PixelPalette.accent
                          : PixelPalette.panelBorder,
                      width: 20,
                    ),
                  ),
                  const SizedBox(width: 6),
                  // La palabra acompaña al color: no es solo visual.
                  Expanded(
                    child: Text(
                      unlocked ? l10n.triviaUnlocked : l10n.triviaLocked,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: unlocked
                            ? PixelPalette.accent
                            : PixelPalette.textMuted,
                        fontVariations: const [FontVariation('wght', 700)],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                data.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontVariations: const [FontVariation('wght', 700)],
                ),
              ),
              Text(
                data.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: PixelPalette.textMuted,
                ),
              ),
              if (!unlocked) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.triviaProgressOf(data.progress, data.target),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: PixelPalette.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                SegmentedBar(
                  // Se pinta a 10 segmentos como máximo.
                  filled: (data.progress / data.target * 10).floor().clamp(
                    0,
                    10,
                  ),
                  total: 10,
                  height: 8,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
