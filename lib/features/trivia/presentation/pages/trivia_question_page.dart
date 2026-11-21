import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';
import 'package:pokedex/features/trivia/presentation/models/trivia_view_data.dart';
import 'package:pokedex/features/trivia/presentation/widgets/stage_background.dart';
import 'package:pokedex/features/trivia/presentation/widgets/trivia_button.dart';
import 'package:pokedex/features/trivia/presentation/widgets/trivia_parts.dart';
import 'package:pokedex/l10n/app_localizations.dart';

const _fieldBorder = OutlineInputBorder(
  borderRadius: BorderRadius.zero,
  borderSide: BorderSide(color: PixelPalette.accent, width: 3),
);

/// Pregunta: silueta, tiempo, casillas de letras y campo para el nombre
/// (RF-TRV-01, RF-TRV-02). Solo muestra lo que recibe.
class TriviaQuestionPage extends StatelessWidget {
  const TriviaQuestionPage({
    required this.data,
    required this.onGuess,
    required this.onHint,
    required this.onSkip,
    super.key,
  });

  final TriviaQuestionData data;
  final VoidCallback onGuess;
  final VoidCallback onHint;
  final VoidCallback onSkip;

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
                  mood: StageMood.warm,
                  minHeight: 350,
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
                            Stack(
                              children: [
                                Center(
                                  child: TriviaSilhouette(
                                    imageUrl: data.imageUrl,
                                    size: 236,
                                  ),
                                ),
                                const Align(
                                  alignment: Alignment.bottomRight,
                                  child: StageQuestionMark(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      StageStrip(
                        child: Row(
                          children: [
                            Text(
                              l10n.triviaSecondsLeft(data.secondsLeft),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SegmentedBar(
                                filled: data.secondsLeft,
                                total: data.totalSeconds,
                              ),
                            ),
                          ],
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
                      // Una casilla por letra. Para el lector de pantalla se
                      // dice solo cuántas letras son.
                      Semantics(
                        label: l10n.triviaLettersLabel(data.nameLength),
                        excludeSemantics: true,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            for (var i = 0; i < data.nameLength; i++)
                              Container(
                                width: 30,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: PixelPalette.background,
                                  border: Border.all(
                                    color: PixelPalette.panelBorder,
                                    width: 3,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        initialValue: data.typedText,
                        textInputAction: TextInputAction.done,
                        autocorrect: false,
                        enableSuggestions: false,
                        onFieldSubmitted: (_) => onGuess(),
                        style: theme.textTheme.titleMedium,
                        decoration: InputDecoration(
                          hintText: l10n.triviaGuessHint,
                          filled: true,
                          fillColor: PixelPalette.background,
                          border: _fieldBorder,
                          enabledBorder: _fieldBorder,
                          focusedBorder: _fieldBorder,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TriviaButton(
                              label: l10n.triviaHintButton(20),
                              kind: TriviaButtonKind.secondary,
                              height: 48,
                              onPressed: onHint,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TriviaButton(
                              label: l10n.triviaSkip,
                              kind: TriviaButtonKind.secondary,
                              height: 48,
                              onPressed: onSkip,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TriviaButton(
                        label: l10n.triviaGuess,
                        height: 54,
                        onPressed: onGuess,
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
