import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';
import 'package:pokedex/features/pokemon/domain/entities/evolution_node.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_extras.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_extras_cubit.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_badge.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_extras_pending.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_labels.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_section_title.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Pestaña Evolución (RF-DET-04): árbol de la cadena evolutiva con la
/// condición de cada paso. Lee del [PokemonExtrasCubit].
class PokemonDetailEvolution extends StatelessWidget {
  const PokemonDetailEvolution({
    required this.currentSpeciesId,
    this.onOpenPokemon,
    super.key,
  });

  /// Especie que se está viendo: se marca como «Actual».
  final int currentSpeciesId;

  /// Se llama con el id de la especie tocada. Si es null, no se puede tocar.
  final ValueChanged<int>? onOpenPokemon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<PokemonExtrasCubit, PokemonExtras>(
      builder: (context, extras) {
        final Widget body;
        final tree = EvolutionNode.fromStages(extras.evolution);

        if (!extras.downloaded) {
          body = const PokemonDetailExtrasPending();
        } else if (tree == null || tree.children.isEmpty) {
          body = Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              l10n.evolutionNone,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          );
        } else {
          body = _EvolutionBranch(
            node: tree,
            currentSpeciesId: currentSpeciesId,
            onOpenPokemon: onOpenPokemon,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [PokemonDetailSectionTitle(l10n.evolutionTitle), body],
        );
      },
    );
  }
}

/// Una especie y, debajo, sus evoluciones.
/// - Un solo hijo (cadena lineal): se dibuja hacia abajo, sin sangría.
/// - Varios hijos (Eevee): se sangran con una línea a la izquierda.
class _EvolutionBranch extends StatelessWidget {
  const _EvolutionBranch({
    required this.node,
    required this.currentSpeciesId,
    required this.onOpenPokemon,
    this.triggerLabel,
    this.indentTrigger = true,
  });

  final EvolutionNode node;
  final int currentSpeciesId;
  final ValueChanged<int>? onOpenPokemon;

  /// Condición para llegar a esta especie. Null en la primera.
  final String? triggerLabel;

  /// Si la flecha de la condición lleva sangría (cadenas lineales).
  final bool indentTrigger;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final children = node.children;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (triggerLabel != null)
          _TriggerRow(label: triggerLabel!, indent: indentTrigger),
        _StageCard(
          node: node,
          isCurrent: node.stage.speciesId == currentSpeciesId,
          onOpenPokemon: onOpenPokemon,
        ),
        if (children.length == 1)
          _EvolutionBranch(
            node: children.first,
            currentSpeciesId: currentSpeciesId,
            onOpenPokemon: onOpenPokemon,
            triggerLabel: evolutionTriggerLabel(l10n, children.first.stage),
          )
        else if (children.length > 1)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: PixelPalette.panelBorder, width: 2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final child in children)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _EvolutionBranch(
                          node: child,
                          currentSpeciesId: currentSpeciesId,
                          onOpenPokemon: onOpenPokemon,
                          triggerLabel: evolutionTriggerLabel(
                            l10n,
                            child.stage,
                          ),
                          indentTrigger: false,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Flecha pixelada + condición en texto amarillo («Nivel 16»).
class _TriggerRow extends StatelessWidget {
  const _TriggerRow({required this.label, required this.indent});

  final String label;
  final bool indent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(indent ? 28 : 0, 4, 0, 4),
      child: Row(
        children: [
          ExcludeSemantics(
            child: CustomPaint(
              size: const Size(10, 22),
              painter: _PixelArrowPainter(theme.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: PixelPalette.accent,
                fontVariations: const [FontVariation('wght', 700)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Flecha hacia abajo hecha con rectángulos, como la del diseño (10×18).
class _PixelArrowPainter extends CustomPainter {
  const _PixelArrowPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const pixels = [
      Rect.fromLTWH(4, 0, 2, 16),
      Rect.fromLTWH(2, 14, 2, 2),
      Rect.fromLTWH(6, 14, 2, 2),
      Rect.fromLTWH(3, 16, 4, 2),
    ];
    for (final pixel in pixels) {
      canvas.drawRect(pixel, paint);
    }
  }

  @override
  bool shouldRepaint(_PixelArrowPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({
    required this.node,
    required this.isCurrent,
    required this.onOpenPokemon,
  });

  final EvolutionNode node;
  final bool isCurrent;
  final ValueChanged<int>? onOpenPokemon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final stage = node.stage;
    final name = prettifySlug(stage.name);
    final number = '#${stage.speciesId.toString().padLeft(4, '0')}';

    // La etapa actual no se abre a sí misma.
    final onTap = (isCurrent || onOpenPokemon == null)
        ? null
        : () => onOpenPokemon!(stage.speciesId);

    // Un solo bloque para el lector: «#0134 Vaporeon, Actual».
    final semanticLabel = isCurrent
        ? '$number $name, ${l10n.evolutionCurrent}'
        : '$number $name';

    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      excludeSemantics: true,
      child: Material(
        color: PixelPalette.panelHigh,
        shape: Border.fromBorderSide(
          BorderSide(
            color: isCurrent ? PixelPalette.accent : PixelPalette.panelBorder,
            width: 3,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  _StageImage(speciesId: stage.speciesId),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          number,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isCurrent ? PixelPalette.accent : null,
                            fontVariations: const [FontVariation('wght', 700)],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCurrent) PokemonDetailBadge(l10n.evolutionCurrent),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Imagen de la etapa dentro de una caja con borde (56×56, como el diseño).
/// En las especies base, el id de la especie es el del Pokémon, por eso sirve
/// para armar la URL del sprite.
///
/// Si el proyecto ya tiene un widget para las imágenes del listado, cambia
/// el `Image.network` por ese para usar la misma caché.
class _StageImage extends StatelessWidget {
  const _StageImage({required this.speciesId});

  final int speciesId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: PixelPalette.panel,
        border: Border.fromBorderSide(
          BorderSide(color: PixelPalette.panelBorder, width: 2),
        ),
      ),
      child: SizedBox(
        width: 56,
        height: 56,
        child: Image.network(
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/'
          'pokemon/$speciesId.png',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.none,
          excludeFromSemantics: true,
          // Sin conexión o sin imagen: un icono, nunca un error en pantalla.
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.catching_pokemon,
            size: 28,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
