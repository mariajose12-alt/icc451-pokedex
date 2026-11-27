import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/pixel_colors.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/type_badge.dart';
import 'package:pokedex/features/trivia/presentation/models/trivia_view_data.dart';
import 'package:pokedex/features/trivia/presentation/widgets/stage_background.dart';
import 'package:pokedex/features/trivia/presentation/widgets/trivia_button.dart';
import 'package:pokedex/features/trivia/presentation/widgets/trivia_parts.dart';
import 'package:pokedex/l10n/app_localizations.dart';
import 'package:pokedex/core/widgets/pixel_panel.dart';

enum TriviaRevealKind { correct, timeUp }

/// Revelación del Pokémon tras una pregunta: acierto o tiempo agotado.
class TriviaRevealPage extends StatelessWidget {
  const TriviaRevealPage({
    required this.kind,
    required this.data,
    required this.onNext,
    super.key,
  });

  final TriviaRevealKind kind;
  final TriviaRevealData data;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final correct = kind == TriviaRevealKind.correct;

    final number = '#${data.pokemonNumber.toString().padLeft(3, '0')}';
    final name = data.pokemonName.isEmpty
        ? data.pokemonName
        : data.pokemonName[0].toUpperCase() + data.pokemonName.substring(1);

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StageBackground.grow(
                  mood: correct ? StageMood.success : StageMood.failure,
                  minHeight: 330,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TriviaHud(
                              questionNumber: data.questionNumber,
                              totalQuestions: data.totalQuestions,
                              score: data.score,
                            ),
                            const SizedBox(height: 10),
                            // liveRegion: el lector de pantalla anuncia el
                            // resultado apenas aparece la pantalla.
                            Semantics(
                              liveRegion: true,
                              child: _Banner(
                                correct: correct,
                                title: correct
                                    ? l10n.triviaCorrect
                                    : l10n.triviaTimeUp,
                                points: '+${data.pointsEarned}',
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: TriviaArtwork(
                                imageUrl: data.imageUrl,
                                size: 150,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StageStrip(child: AnswerDots(dots: data.dots)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        correct ? number : l10n.triviaWasNumber(number),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: context.pixel.textMuted,
                          fontVariations: const [FontVariation('wght', 700)],
                        ),
                      ),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 32,
                          fontVariations: const [FontVariation('wght', 700)],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final type in data.typeNames)
                            TypeBadge(typeName: type),
                        ],
                      ),
                      const SizedBox(height: 14),
                      PixelPanel(
                        padding: const EdgeInsets.all(10),
                        child: correct
                            ? Column(
                                children: [
                                  _Row(
                                    l10n.triviaBreakdownHit,
                                    '+${data.basePoints}',
                                  ),
                                  const SizedBox(height: 4),
                                  _Row(
                                    l10n.triviaBreakdownSpeed(data.secondsUsed),
                                    '+${data.speedBonus}',
                                  ),
                                  if (data.hintPenalty > 0) ...[
                                    const SizedBox(height: 4),
                                    _Row(
                                      l10n.triviaBreakdownHints(data.hintCount),
                                      '−${data.hintPenalty}',
                                    ),
                                  ],
                                ],
                              )
                            : Text(
                                l10n.triviaStreakReset(data.streakLost),
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: context.pixel.textMuted,
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                      TriviaButton(
                        label: l10n.triviaNext,
                        height: 54,
                        onPressed: onNext,
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

/// Cartel de resultado. Lleva ✓ o ✕ además del color (RNF-ACC-05).
class _Banner extends StatelessWidget {
  const _Banner({
    required this.correct,
    required this.title,
    required this.points,
  });

  final bool correct;
  final String title;
  final String points;

  @override
  Widget build(BuildContext context) {
    final fg = correct ? PixelPalette.background : Colors.white;
    final style = Theme.of(context).textTheme.titleLarge?.copyWith(
      color: fg,
      fontVariations: const [FontVariation('wght', 700)],
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: correct ? PixelPalette.success : PixelPalette.shell,
        border: Border.all(color: PixelPalette.background, width: 3),
        boxShadow: const [
          BoxShadow(color: PixelPalette.shadow, offset: Offset(4, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Row(
          children: [
            ExcludeSemantics(child: Text(correct ? '✓' : '✕', style: style)),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: style)),
            Text(points, style: style),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.pixel.textMuted,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontVariations: const [FontVariation('wght', 700)],
          ),
        ),
      ],
    );
  }
}
