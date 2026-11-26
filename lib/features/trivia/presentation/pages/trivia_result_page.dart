import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/pixel_colors.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';
import 'package:pokedex/core/widgets/pixel_panel.dart';
import 'package:pokedex/core/widgets/pixel_sprite.dart';
import 'package:pokedex/features/trivia/presentation/models/trivia_view_data.dart';
import 'package:pokedex/features/trivia/presentation/widgets/stage_background.dart';
import 'package:pokedex/features/trivia/presentation/widgets/trivia_button.dart';
import 'package:pokedex/features/trivia/presentation/widgets/trivia_parts.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Resultado de la partida (RF-TRV-02, RF-TRV-04): puntaje, aciertos y el
/// logro desbloqueado, si lo hubo.
class TriviaResultPage extends StatelessWidget {
  const TriviaResultPage({
    required this.data,
    required this.onPlayAgain,
    required this.onRanking,
    required this.onHome,
    super.key,
  });

  final TriviaResultData data;
  final VoidCallback onPlayAgain;
  final VoidCallback onRanking;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final achievement = data.achievementName;

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
                  minHeight: 340,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TriviaPill(
                          l10n.triviaGameOver,
                          color: PixelPalette.accent,
                          letterSpacing: 2,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const PixelSprite(
                              sprite: PixelSprites.cup,
                              color: PixelPalette.background,
                              width: 112,
                            ),
                            // El puntaje grande se encoge si no cabe.
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                l10n.triviaNumber(data.score),
                                style: const TextStyle(
                                  fontSize: 76,
                                  height: 1.1,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  shadows: [
                                    Shadow(
                                      color: PixelPalette.background,
                                      offset: Offset(5, 5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (data.newRecord)
                          TriviaPill(
                            l10n.triviaNewRecord,
                            color: PixelPalette.accent,
                            fontSize: 15,
                          )
                        else
                          const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PixelPanel(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.triviaCorrectLabel,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: context.pixel.textMuted,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    l10n.triviaCorrectOf(
                                      data.correctCount,
                                      data.total,
                                    ),
                                    textAlign: TextAlign.end,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontVariations: const [
                                        FontVariation('wght', 700),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            AnswerDots(dots: data.dots),
                          ],
                        ),
                      ),
                      if (achievement != null) ...[
                        const SizedBox(height: 14),
                        _AchievementCard(
                          title: l10n.triviaAchievementUnlocked,
                          name: achievement,
                          description: data.achievementDescription ?? '',
                        ),
                      ],
                      const SizedBox(height: 20),
                      TriviaButton(
                        label: l10n.triviaPlayAgain,
                        height: 54,
                        onPressed: onPlayAgain,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TriviaButton(
                              label: l10n.triviaSeeRanking,
                              kind: TriviaButtonKind.secondary,
                              height: 48,
                              onPressed: onRanking,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TriviaButton(
                              label: l10n.triviaBackHome,
                              kind: TriviaButtonKind.secondary,
                              height: 48,
                              onPressed: onHome,
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

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.title,
    required this.name,
    required this.description,
  });

  final String title;
  final String name;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.pixel.panelHigh,
          border: Border.all(color: context.pixel.accent, width: 3),
          boxShadow: [
            BoxShadow(color: context.pixel.shadow, offset: const Offset(4, 4)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: PixelPalette.accent,
                  border: Border.all(color: PixelPalette.background, width: 3),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: PixelSprite(
                    sprite: PixelSprites.star,
                    color: PixelPalette.background,
                    width: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: context.pixel.accentText,
                        fontVariations: const [FontVariation('wght', 700)],
                      ),
                    ),
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontVariations: const [FontVariation('wght', 700)],
                      ),
                    ),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: context.pixel.textMuted,
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
