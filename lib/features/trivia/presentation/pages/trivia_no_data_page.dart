import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/pixel_colors.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';
import 'package:pokedex/core/widgets/pixel_panel.dart';
import 'package:pokedex/features/trivia/presentation/models/trivia_view_data.dart';
import 'package:pokedex/features/trivia/presentation/widgets/stage_background.dart';
import 'package:pokedex/features/trivia/presentation/widgets/trivia_button.dart';
import 'package:pokedex/features/trivia/presentation/widgets/trivia_parts.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Estado "no hay suficientes Pokémon guardados" (RF-TRV-05). Explica qué
/// pasa y ofrece dos salidas; el ranking y los logros siguen disponibles.
class TriviaNoDataPage extends StatelessWidget {
  const TriviaNoDataPage({
    required this.data,
    required this.onGoCatalog,
    required this.onRetry,
    super.key,
  });

  final TriviaNoDataData data;
  final VoidCallback onGoCatalog;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StageBackground.grow(
                  mood: StageMood.dim,
                  minHeight: 280,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TriviaPill(
                              l10n.triviaNoDataBadge,
                              color: PixelPalette.accent,
                              letterSpacing: 2,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.triviaNoDataTitle,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontSize: 28,
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
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 8, 24, 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: StageQuestionMark(size: 72),
                        ),
                      ),
                      StageStrip(
                        child: Semantics(
                          label: l10n.triviaNoDataProgress(
                            data.saved,
                            data.required,
                          ),
                          excludeSemantics: true,
                          child: Row(
                            children: [
                              Text(
                                l10n.triviaCorrectOf(data.saved, data.required),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontVariations: const [
                                    FontVariation('wght', 700),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SegmentedBar(
                                  filled: data.saved.clamp(0, data.required),
                                  total: data.required,
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
                      Text(
                        l10n.triviaNoDataMessage(data.required),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: context.pixel.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TriviaButton(
                        label: l10n.triviaGoCatalog,
                        height: 54,
                        onPressed: onGoCatalog,
                      ),
                      const SizedBox(height: 8),
                      TriviaButton(
                        label: l10n.triviaRetry,
                        kind: TriviaButtonKind.secondary,
                        height: 48,
                        onPressed: onRetry,
                      ),
                      const SizedBox(height: 16),
                      PixelPanel(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          l10n.triviaNoDataNote,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: context.pixel.textMuted,
                          ),
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
