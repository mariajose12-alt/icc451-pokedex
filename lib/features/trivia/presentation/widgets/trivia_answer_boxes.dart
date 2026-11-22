import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';
import 'package:pokedex/features/trivia/domain/usecases/normalize_answer.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Campo de respuesta dibujado como casillas: lo que se escribe aparece
/// letra por letra dentro de ellas (RF-TRV-01).
class TriviaAnswerBoxes extends StatelessWidget {
  const TriviaAnswerBoxes({
    required this.controller,
    required this.length,
    required this.hintLetters,
    required this.onSubmit,
    super.key,
  });

  final TextEditingController controller;

  /// Cuántas casillas se dibujan (letras del nombre sin signos).
  final int length;

  /// Letras reveladas por las pistas (se ven atenuadas hasta que se escriban).
  final String hintLetters;

  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      label: l10n.triviaLettersLabel(length),
      container: true,
      child: Stack(
        children: [
          // Campo real: da el teclado, el pegado y la accesibilidad. No dibuja
          // nada propio.
          Positioned.fill(
            child: TextField(
              controller: controller,
              autofocus: true,
              autocorrect: false,
              enableSuggestions: false,
              enableInteractiveSelection: false,
              showCursor: false,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onSubmit(),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp('[a-zA-Z0-9áéíóúüñÁÉÍÓÚÜÑ]'),
                ),
                LengthLimitingTextInputFormatter(length),
              ],
              style: const TextStyle(color: Colors.transparent),
              cursorColor: Colors.transparent,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          // Las casillas no reciben toques: pasan al campo de abajo.
          IgnorePointer(
            child: ExcludeSemantics(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  final typed = normalizeAnswer(value.text);
                  return SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        for (var i = 0; i < length; i++)
                          _LetterBox(
                            letter: i < typed.length
                                ? typed[i]
                                : (i < hintLetters.length
                                      ? hintLetters[i]
                                      : ''),
                            isHint: i >= typed.length && i < hintLetters.length,
                            isNext: i == typed.length,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LetterBox extends StatelessWidget {
  const _LetterBox({
    required this.letter,
    required this.isHint,
    required this.isNext,
  });

  final String letter;
  final bool isHint;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: PixelPalette.background,
        border: Border.all(
          color: isNext ? PixelPalette.accent : PixelPalette.panelBorder,
          width: 3,
        ),
      ),
      // FittedBox: con texto del sistema al 200 % la letra se encoge.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          letter.toUpperCase(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: isHint ? PixelPalette.textMuted : PixelPalette.text,
          ),
        ),
      ),
    );
  }
}
