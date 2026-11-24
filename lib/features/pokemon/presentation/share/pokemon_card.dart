import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/features/pokemon/presentation/share/pokemon_card_data.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/type_badge.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// La Pokémon Card (RF-COM-01): una imagen para compartir.
///
/// Mide siempre 378×528 y NO sigue el tamaño de letra del sistema: la imagen
/// debe verse igual en cualquier teléfono. Los colores salen de un solo
/// color base (el del tipo principal).
class PokemonCard extends StatelessWidget {
  const PokemonCard({required this.data, super.key});

  static const double width = 378;
  static const double height = 528;

  final PokemonCardData data;

  // Mismo color con otra luminosidad.
  static Color _tone(Color color, double lightness) {
    return HSLColor.fromColor(color).withLightness(lightness).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fontFamily = Theme.of(context).textTheme.bodyMedium?.fontFamily;
    final accent = data.accentColor;
    final number = data.nationalDexNumber.toString().padLeft(3, '0');

    return MediaQuery(
      // La carta es una imagen: no crece con el texto del sistema.
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Semantics(
        container: true,
        label: l10n.pokemonSemanticLabel(
          data.name,
          data.nationalDexNumber,
          data.typeNames.join(', '),
        ),
        child: ExcludeSemantics(
          child: DefaultTextStyle.merge(
            style: const TextStyle(color: Colors.white),
            child: SizedBox(
              width: width,
              height: height,
              child: DecoratedBox(
                // Marco: degradado claro → color → oscuro.
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_tone(accent, 0.88), accent, _tone(accent, 0.22)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.24),
                          radius: 1,
                          colors: [
                            _tone(accent, 0.8),
                            accent,
                            _tone(accent, 0.28),
                            _tone(accent, 0.1),
                          ],
                          stops: const [0, 0.3, 0.65, 1],
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Rayos que salen de detrás del Pokémon.
                          const Positioned.fill(
                            child: CustomPaint(painter: _RaysPainter()),
                          ),
                          // Número gigante, solo el contorno.
                          Positioned(
                            top: 62,
                            left: 0,
                            right: 0,
                            child: Text(
                              number,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: fontFamily,
                                fontSize: 150,
                                fontWeight: FontWeight.w700,
                                height: 1,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 2
                                  ..color = const Color(0x47FFFFFF),
                              ),
                            ),
                          ),
                          const _Sparkle(left: 36, top: 120, size: 9),
                          const _Sparkle(right: 40, top: 100, size: 7),
                          const _Sparkle(right: 64, top: 230, size: 10),
                          const _Sparkle(left: 60, top: 250, size: 6),
                          Positioned(
                            left: 14,
                            right: 14,
                            top: 12,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Flexible: el recuadro cede espacio a las
                                // etiquetas de tipo y recorta con «…» si no
                                // cabe, así la fila nunca se desborda.
                                Flexible(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: const Color(0xB30A1A12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      child: Text(
                                        l10n.cardNationalDex,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Wrap(
                                  spacing: 5,
                                  children: [
                                    for (final type in data.typeNames)
                                      TypeBadge(typeName: type),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // El artwork, grande y centrado sobre los rayos.
                          Positioned(
                            top: 52,
                            left: 50,
                            right: 50,
                            height: 214,
                            child: _Artwork(url: data.imageUrl),
                          ),
                          Positioned(
                            left: 10,
                            right: 10,
                            bottom: 10,
                            child: _InfoPanel(data: data),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  const _Artwork({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    const fallback = Icon(
      Icons.catching_pokemon,
      size: 96,
      color: Color(0x99FFFFFF),
    );

    final imageUrl = url;
    if (imageUrl == null || imageUrl.isEmpty) {
      return const Center(child: fallback);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.contain,
      // Más resolución que en las listas: es una imagen para guardar.
      memCacheWidth: 600,
      fadeInDuration: Duration.zero,
      placeholder: (context, url) => const Center(child: fallback),
      errorWidget: (context, url, error) => const Center(child: fallback),
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({
    this.left,
    this.right,
    required this.top,
    required this.size,
  });

  final double? left;
  final double? right;
  final double top;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      child: Transform.rotate(
        angle: math.pi / 4,
        child: SizedBox(
          width: size,
          height: size,
          child: const ColoredBox(color: Color(0xE6FFFFFF)),
        ),
      ),
    );
  }
}

/// Panel oscuro de abajo: nombre, total, stats y datos.
class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.data});

  final PokemonCardData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final firstColumn = data.stats.take(3).toList();
    final secondColumn = data.stats.skip(3).take(3).toList();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xC7081610),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x4DFFFFFF), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    data.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
                Text(
                  '${l10n.cardTotal} ',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFA9D8B0),
                  ),
                ),
                Text(
                  '${data.total}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFFD86B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _StatColumn(stats: firstColumn)),
                const SizedBox(width: 14),
                Expanded(child: _StatColumn(stats: secondColumn)),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: Color(0x33FFFFFF)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _InfoItem(
                    label: l10n.cardHeightWeight,
                    value: data.heightWeight,
                    labelColor: const Color(0xFFA9D8B0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoItem(
                    label: l10n.cardAbilities,
                    value: data.abilities,
                    labelColor: const Color(0xFFA9D8B0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _InfoItem(
                    label: l10n.cardWeakTo,
                    value: data.weakTo,
                    labelColor: const Color(0xFFFF9A9A),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoItem(
                    label: l10n.cardResists,
                    value: data.resists,
                    labelColor: const Color(0xFF7DF3B0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.cardFooter,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFFA9D8B0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.stats});

  final List<PokemonCardStat> stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0) const SizedBox(height: 5),
          _StatRow(stat: stats[i]),
        ],
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.stat});

  final PokemonCardStat stat;

  // Referencia para la barra llena: 255 es el máximo posible de una stat.
  static const _maxStat = 255;

  @override
  Widget build(BuildContext context) {
    final fraction = (stat.value / _maxStat).clamp(0.0, 1.0);

    return Row(
      children: [
        SizedBox(
          width: 30,
          child: Text(
            stat.label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFFA9D8B0),
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 7,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: Color(0x26FFFFFF)),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: fraction,
                    child: const ColoredBox(color: Color(0xFFFFD86B)),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          width: 26,
          child: Text(
            '${stat.value}',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.label,
    required this.value,
    required this.labelColor,
  });

  final String label;
  final String value;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: labelColor,
          ),
        ),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

/// Rayos claros que salen del centro del arte.
class _RaysPainter extends CustomPainter {
  const _RaysPainter();

  static const _rays = 18;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.38);
    final reach = size.longestSide * 1.5;
    final paint = Paint()..color = const Color(0x1FFFFFFF);
    const step = 2 * math.pi / _rays;

    // Un rayo sí, uno no: cada uno cubre la mitad del paso.
    for (var i = 0; i < _rays; i++) {
      final start = i * step;
      final end = start + step / 2;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + reach * math.cos(start),
          center.dy + reach * math.sin(start),
        )
        ..lineTo(
          center.dx + reach * math.cos(end),
          center.dy + reach * math.sin(end),
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_RaysPainter oldDelegate) => false;
}
