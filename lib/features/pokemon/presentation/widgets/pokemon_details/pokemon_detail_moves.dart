import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';
import 'package:pokedex/features/pokemon/domain/entities/move_learn_method.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_move.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_moves_cubit.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_moves_state.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_card.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_extras_pending.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_labels.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_version_sheet.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Pestaña Movs. (RF-DET-05). Devuelve un SLIVER: controles arriba y la lista
/// virtualizada (SliverList.builder) debajo, dentro del mismo scroll.
class PokemonDetailMoves extends StatelessWidget {
  const PokemonDetailMoves({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PokemonMovesCubit, PokemonMovesState>(
      builder: (context, state) {
        // Sin versiones: todavía no se descargó el detalle.
        if (state.versionGroups.isEmpty) {
          return const SliverToBoxAdapter(child: PokemonDetailExtrasPending());
        }

        final isEmpty = state.movesLoaded && state.moves.isEmpty;

        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(child: _MovesControls(state: state)),
            if (isEmpty)
              const SliverToBoxAdapter(child: _EmptyMoves())
            else
              // Solo se construyen las filas que se ven (RNF-REN-01).
              DecoratedSliver(
                decoration: const BoxDecoration(
                  border: Border.fromBorderSide(
                    BorderSide(color: PixelPalette.panelBorder, width: 2),
                  ),
                ),
                sliver: SliverList.builder(
                  itemCount: state.moves.length,
                  itemBuilder: (context, index) => _MoveRow(
                    move: state.moves[index],
                    method: state.method,
                    shaded: index.isOdd,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MovesControls extends StatelessWidget {
  const _MovesControls({required this.state});

  final PokemonMovesState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _VersionButton(state: state),
          const SizedBox(height: 10),
          _MethodTabs(selected: state.method),
          // El orden por nivel solo tiene sentido con el método Nivel.
          if (state.method == MoveLearnMethod.levelUp) ...[
            const SizedBox(height: 10),
            _OrderRow(selected: state.order),
          ],
        ],
      ),
    );
  }
}

class _VersionButton extends StatelessWidget {
  const _VersionButton({required this.state});

  final PokemonMovesState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final group = state.selectedVersionGroup;
    final name = group == null ? '' : prettifySlug(group.name);

    return Semantics(
      button: true,
      label: l10n.movesVersionButtonLabel(name),
      excludeSemantics: true,
      child: Material(
        color: PixelPalette.panelHigh,
        shape: const Border.fromBorderSide(
          BorderSide(color: PixelPalette.panelBorder, width: 3),
        ),
        child: InkWell(
          onTap: () async {
            final picked = await showPokemonVersionSheet(
              context,
              groups: state.versionGroups,
              selectedId: state.versionGroupId,
            );
            if (picked != null && context.mounted) {
              context.read<PokemonMovesCubit>().selectVersionGroup(picked);
            }
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.movesVersionLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontVariations: const [FontVariation('wght', 700)],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Nivel / MT / Tutor / Huevo. Con el texto muy grande pasan a dos filas.
class _MethodTabs extends StatelessWidget {
  const _MethodTabs({required this.selected});

  final MoveLearnMethod selected;

  static const _methods = [
    MoveLearnMethod.levelUp,
    MoveLearnMethod.machine,
    MoveLearnMethod.tutor,
    MoveLearnMethod.egg,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final columns = MediaQuery.textScalerOf(context).scale(14) <= 19 ? 4 : 2;

    return Semantics(
      container: true,
      label: l10n.movesMethodsLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = 6.0;
          final width = (constraints.maxWidth - gap * (columns - 1)) / columns;

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final method in _methods)
                SizedBox(
                  width: width,
                  child: _ChoiceButton(
                    label: moveMethodLabel(l10n, method),
                    isSelected: method == selected,
                    onTap: () =>
                        context.read<PokemonMovesCubit>().selectMethod(method),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// «Ordenar por: Nivel · Nombre».
class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.selected});

  final MovesOrder selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          l10n.movesOrderLabel,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        for (final order in MovesOrder.values)
          SizedBox(
            width: 110,
            child: _ChoiceButton(
              label: order == MovesOrder.level
                  ? l10n.movesOrderLevel
                  : l10n.movesOrderName,
              isSelected: order == selected,
              onTap: () => context.read<PokemonMovesCubit>().selectOrder(order),
            ),
          ),
      ],
    );
  }
}

/// Botón de elección: amarillo si está elegido. Además del color, el lector
/// de pantalla dice «seleccionado».
class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: isSelected ? PixelPalette.accent : PixelPalette.panelHigh,
        shape: Border.fromBorderSide(
          BorderSide(
            color: isSelected ? PixelPalette.accent : PixelPalette.panelBorder,
            width: 3,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isSelected ? PixelPalette.background : null,
                  fontVariations: const [FontVariation('wght', 700)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MoveRow extends StatelessWidget {
  const _MoveRow({
    required this.move,
    required this.method,
    required this.shaded,
  });

  final PokemonMove move;
  final MoveLearnMethod method;
  final bool shaded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Con nivel: «Nv.7». Con los demás métodos: «MT», «Tutor», «Huevo».
    final tag = method == MoveLearnMethod.levelUp
        ? l10n.movesLevelTag(move.level)
        : moveMethodLabel(l10n, method);

    // MergeSemantics: «Nv.7, Ember» se lee como una sola fila.
    return MergeSemantics(
      child: ColoredBox(
        color: shaded ? PixelPalette.panelHigh : PixelPalette.panel,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 44),
                  child: ColoredBox(
                    color: PixelPalette.accent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: Text(
                        tag,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: PixelPalette.background,
                          fontVariations: const [FontVariation('wght', 700)],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    prettifySlug(move.name),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontVariations: const [FontVariation('wght', 700)],
                    ),
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

class _EmptyMoves extends StatelessWidget {
  const _EmptyMoves();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return PokemonDetailCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          Text(
            l10n.movesEmptyTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              fontVariations: const [FontVariation('wght', 700)],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.movesEmptyMessage,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
