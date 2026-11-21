import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Texto sobre una píldora oscura: se lee sobre cualquier escenario.
class TriviaPill extends StatelessWidget {
  const TriviaPill(
    this.text, {
    this.color = PixelPalette.text,
    this.fontSize = 13,
    this.letterSpacing = 0,
    super.key,
  });

  final String text;
  final Color color;
  final double fontSize;
  final double letterSpacing;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: PixelPalette.background),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: fontSize,
            color: color,
            letterSpacing: letterSpacing,
            fontVariations: const [FontVariation('wght', 700)],
          ),
        ),
      ),
    );
  }
}

/// «Pregunta 3/10» a la izquierda y los puntos a la derecha.
class TriviaHud extends StatelessWidget {
  const TriviaHud({
    required this.questionNumber,
    required this.totalQuestions,
    required this.score,
    super.key,
  });

  final int questionNumber;
  final int totalQuestions;
  final int score;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Wrap en vez de Row: si no caben en una línea (texto grande), los puntos
    // pasan a la línea de abajo en lugar de desbordar.
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: [
        TriviaPill(l10n.triviaQuestionProgress(questionNumber, totalQuestions)),
        TriviaPill(
          l10n.triviaPoints(score),
          color: PixelPalette.accent,
          fontSize: 18,
        ),
      ],
    );
  }
}

/// Franja oscura en la base del escenario.
class StageStrip extends StatelessWidget {
  const StageStrip({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: PixelPalette.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: child,
      ),
    );
  }
}

/// El «?» grande decorativo de las esquinas del escenario.
class StageQuestionMark extends StatelessWidget {
  const StageQuestionMark({
    this.size = 56,
    this.color = Colors.white,
    super.key,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Text(
        '?',
        // Es un adorno: no crece con el texto del sistema.
        textScaler: TextScaler.noScaling,
        style: TextStyle(
          fontSize: size,
          height: 1,
          color: color,
          fontWeight: FontWeight.w700,
          shadows: const [
            Shadow(color: PixelPalette.background, offset: Offset(4, 4)),
          ],
        ),
      ),
    );
  }
}

/// Barra de segmentos (tiempo restante, progreso de logros...).
/// Siempre va acompañada de un número o texto: no depende del color.
class SegmentedBar extends StatelessWidget {
  const SegmentedBar({
    required this.filled,
    required this.total,
    this.color = PixelPalette.accent,
    this.height = 12,
    super.key,
  });

  final int filled;
  final int total;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        children: [
          for (var i = 0; i < total; i++)
            Expanded(
              child: Container(
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: i < filled ? color : PixelPalette.panelHigh,
                  border: Border.all(color: PixelPalette.background, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum AnswerDotState { correct, wrong, current, pending }

/// Una casilla por pregunta: ✓ acierto, ✕ fallo. La marca acompaña al color.
class AnswerDots extends StatelessWidget {
  const AnswerDots({required this.dots, super.key});

  final List<AnswerDotState> dots;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final correct = dots.where((d) => d == AnswerDotState.correct).length;

    return Semantics(
      label: l10n.triviaDotsLabel(correct, dots.length),
      excludeSemantics: true,
      child: Row(
        children: [
          for (final dot in dots)
            Expanded(
              child: Container(
                height: 22,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: switch (dot) {
                    AnswerDotState.correct => PixelPalette.success,
                    AnswerDotState.wrong => PixelPalette.shell,
                    AnswerDotState.current => PixelPalette.accent,
                    AnswerDotState.pending => PixelPalette.panelHigh,
                  },
                  border: Border.all(color: PixelPalette.background, width: 2),
                ),
                child: Text(
                  switch (dot) {
                    AnswerDotState.correct => '✓',
                    AnswerDotState.wrong => '✕',
                    _ => '',
                  },
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: dot == AnswerDotState.wrong
                        ? Colors.white
                        : PixelPalette.background,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Silueta de un Pokémon: su artwork pintado de un solo color. Los lectores
/// de pantalla NO reciben el nombre (sería regalar la respuesta).
class TriviaSilhouette extends StatelessWidget {
  const TriviaSilhouette({required this.imageUrl, this.size = 220, super.key});

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final url = imageUrl;

    // Misma imagen con un color plano. srcIn conserva solo la forma.
    Widget tinted(Color color) => ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      child: url == null
          ? Icon(Icons.catching_pokemon, size: size * 0.6)
          : CachedNetworkImage(
              imageUrl: url,
              width: size,
              height: size,
              fit: BoxFit.contain,
              memCacheWidth: 600,
              placeholder: (_, _) => const SizedBox.shrink(),
              errorWidget: (_, _, _) =>
                  Icon(Icons.catching_pokemon, size: size * 0.6),
            ),
    );

    return Semantics(
      label: l10n.triviaSilhouetteLabel,
      image: true,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Sombra dura desplazada.
            Transform.translate(
              offset: const Offset(5, 5),
              child: tinted(const Color(0x59000000)),
            ),
            tinted(PixelPalette.background),
          ],
        ),
      ),
    );
  }
}

/// El artwork ya revelado (a color).
class TriviaArtwork extends StatelessWidget {
  const TriviaArtwork({required this.imageUrl, this.size = 150, super.key});

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    // El nombre ya está escrito debajo: la imagen es decorativa.
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: url == null
            ? Icon(Icons.catching_pokemon, size: size * 0.6)
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                memCacheWidth: 600,
                placeholder: (_, _) => const SizedBox.shrink(),
                errorWidget: (_, _, _) =>
                    Icon(Icons.catching_pokemon, size: size * 0.6),
              ),
      ),
    );
  }
}
