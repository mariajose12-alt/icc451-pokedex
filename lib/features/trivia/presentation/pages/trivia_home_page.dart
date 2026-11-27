import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/pixel_colors.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';
import 'package:pokedex/core/widgets/pixel_panel.dart';
import 'package:pokedex/features/trivia/presentation/models/trivia_view_data.dart';
import 'package:pokedex/features/trivia/presentation/widgets/stage_background.dart';
import 'package:pokedex/features/trivia/presentation/widgets/trivia_button.dart';
import 'package:pokedex/features/trivia/presentation/widgets/trivia_parts.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Inicio de la trivia: escenario con la silueta, récords y botones.
/// No decide nada: recibe datos y avisa con callbacks.
class TriviaHomePage extends StatelessWidget {
  const TriviaHomePage({
    required this.data,
    required this.onPlay,
    required this.onRanking,
    required this.onAchievements,
    super.key,
  });

  final TriviaHomeData data;
  final VoidCallback onPlay;
  final VoidCallback onRanking;
  final VoidCallback onAchievements;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            // En pantallas anchas el contenido no se estira (RF-CAT-06).
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StageBackground.grow(
                  mood: StageMood.warm,
                  minHeight: 340,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                      child: Column(
                        // Todo centrado en el escenario.
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TriviaPill(
                            l10n.triviaBadge,
                            color: PixelPalette.accent,
                            letterSpacing: 2,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.triviaTitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontSize: 30,
                              height: 1.02,
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
                          const SizedBox(height: 12),
                          TriviaSilhouette(
                            imageUrl: data.silhouetteUrl,
                            size: 215,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: l10n.triviaStatBest,
                              value: l10n.triviaNumber(data.bestScore),
                              highlight: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              label: l10n.triviaStatStreak,
                              value: l10n.triviaNumber(data.streak),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              label: l10n.triviaStatGames,
                              value: l10n.triviaNumber(data.gamesPlayed),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l10n.triviaRules,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: context.pixel.textMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TriviaButton(
                        label: l10n.triviaPlay,
                        height: 60,
                        onPressed: onPlay,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TriviaButton(
                              label: l10n.triviaRanking,
                              kind: TriviaButtonKind.secondary,
                              onPressed: onRanking,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TriviaButton(
                              label: l10n.triviaAchievements,
                              kind: TriviaButtonKind.secondary,
                              onPressed: onAchievements,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ExcludeSemantics(
                            child: SizedBox.square(
                              dimension: 10,
                              child: ColoredBox(color: context.pixel.success),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.triviaSavedCount(data.savedPokemon),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: context.pixel.textMuted,
                              ),
                            ),
                          ),
                        ],
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PixelPanel(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: context.pixel.textMuted,
              fontVariations: const [FontVariation('wght', 700)],
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              color: highlight ? context.pixel.accentText : context.pixel.text,
              fontVariations: const [FontVariation('wght', 700)],
            ),
          ),
        ],
      ),
    );
  }
}
