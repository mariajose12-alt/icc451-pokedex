import 'package:flutter/material.dart';
import 'package:pokedex/features/trivia/presentation/models/trivia_view_data.dart';
import 'package:pokedex/features/trivia/presentation/widgets/stage_background.dart';
import 'package:pokedex/features/trivia/presentation/widgets/trivia_button.dart';
import 'package:pokedex/features/trivia/presentation/widgets/trivia_parts.dart';
import 'package:pokedex/features/trivia/presentation/widgets/trivia_answer_boxes.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Pregunta: silueta, tiempo, casillas de letras y campo para el nombre
/// (RF-TRV-01, RF-TRV-02). Solo muestra lo que recibe.
class TriviaQuestionPage extends StatelessWidget {
  const TriviaQuestionPage({
    required this.data,
    required this.onGuess,
    required this.onHint,
    required this.onSkip,
    required this.controller,
    required this.onImageReady,
    super.key,
  });

  final TriviaQuestionData data;
  final VoidCallback onGuess;
  final VoidCallback onHint;
  final VoidCallback onSkip;
  final TextEditingController controller;
  final VoidCallback onImageReady;

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
                                    onReady: onImageReady,
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
                      // El único campo de respuesta: se escribe sobre las casillas.
                      TriviaAnswerBoxes(
                        controller: controller,
                        length: data.nameLength,
                        hintLetters: data.revealedLetters,
                        onSubmit: onGuess,
                      ),
                      const SizedBox(height: 16),
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
