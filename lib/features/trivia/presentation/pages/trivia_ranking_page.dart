import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pokedex/core/theme/pixel_colors.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';
import 'package:pokedex/core/widgets/pixel_panel.dart';
import 'package:pokedex/features/trivia/presentation/models/trivia_view_data.dart';
import 'package:pokedex/features/trivia/presentation/widgets/stage_background.dart';
import 'package:pokedex/features/trivia/presentation/widgets/trivia_button.dart';
import 'package:pokedex/features/trivia/presentation/widgets/trivia_parts.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Ranking local (RF-TRV-03): podio con los 3 mejores y lista del resto.
/// Las entradas llegan ya ordenadas de mayor a menor puntaje.
class TriviaRankingPage extends StatelessWidget {
  const TriviaRankingPage({
    required this.entries,
    required this.onBack,
    super.key,
  });

  final List<TriviaRankingEntry> entries;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final podium = entries.take(3).toList();
    final rest = entries.skip(3).toList();
    final dateFormat = DateFormat.MMMd(
      Localizations.localeOf(context).toString(),
    );

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          // Lista perezosa: solo se construyen las filas visibles (RNF-REN-01).
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: StageBackground.grow(
                  mood: StageMood.purple,
                  minHeight: 340,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TriviaPill(
                              l10n.triviaRankingSubtitle.toUpperCase(),
                              color: PixelPalette.accent,
                              letterSpacing: 2,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.triviaRanking,
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
                        const SizedBox(height: 12),
                        _Podium(entries: podium),
                      ],
                    ),
                  ),
                ),
              ),
              if (entries.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: PixelPanel(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          Text(
                            l10n.triviaRankingEmptyTitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.triviaRankingEmptyMessage,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: context.pixel.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverList.separated(
                    itemCount: rest.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => _RankRow(
                      position: index + 4,
                      entry: rest[index],
                      dateText: dateFormat.format(rest[index].date),
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: TriviaButton(
                    label: l10n.triviaBack,
                    kind: TriviaButtonKind.secondary,
                    height: 48,
                    onPressed: onBack,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Podio con orden visual 2.º · 1.º · 3.º.
class _Podium extends StatelessWidget {
  const _Podium({required this.entries});

  final List<TriviaRankingEntry> entries;

  // Altura del bloque según el puesto (índice 0 = 1.º).
  static const _heights = [96.0, 70.0, 52.0];
  static const _colors = [
    PixelPalette.accent,
    Color(0xFFC9D2E8),
    Color(0xFFD08A4A),
  ];

  @override
  Widget build(BuildContext context) {
    // Orden visual: segundo, primero, tercero.
    final visualOrder = [1, 0, 2].where((i) => i < entries.length);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final i in visualOrder)
          Expanded(
            child: _PodiumSlot(
              position: i + 1,
              entry: entries[i],
              height: _heights[i],
              color: _colors[i],
            ),
          ),
      ],
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  const _PodiumSlot({
    required this.position,
    required this.entry,
    required this.height,
    required this.color,
  });

  final int position;
  final TriviaRankingEntry entry;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Se lee una sola frase: «Puesto 1: 1 240 puntos».
    return Semantics(
      label: l10n.triviaPodiumLabel(position, entry.score),
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (entry.isNew)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: TriviaPill(
                l10n.triviaNewTag,
                color: PixelPalette.accent,
                fontSize: 11,
              ),
            ),
          // FittedBox: el puntaje se encoge en lugar de desbordar.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                l10n.triviaNumber(entry.score),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  shadows: [
                    Shadow(
                      color: PixelPalette.background,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: PixelPalette.background, width: 3),
            ),
            // El número del puesto acompaña al color.
            child: Text(
              '$position',
              textScaler: TextScaler.noScaling,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: PixelPalette.background,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.position,
    required this.entry,
    required this.dateText,
  });

  final int position;
  final TriviaRankingEntry entry;
  final String dateText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return PixelPanel(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '$position',
              style: theme.textTheme.titleLarge?.copyWith(
                color: context.pixel.textMuted,
                fontVariations: const [FontVariation('wght', 700)],
              ),
            ),
          ),
          Expanded(
            child: Text(
              l10n.triviaRankingRowDetail(
                entry.correctCount,
                entry.total,
                dateText,
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: context.pixel.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.triviaPoints(entry.score),
            style: theme.textTheme.titleMedium?.copyWith(
              color: context.pixel.accentText,
              fontVariations: const [FontVariation('wght', 700)],
            ),
          ),
        ],
      ),
    );
  }
}
