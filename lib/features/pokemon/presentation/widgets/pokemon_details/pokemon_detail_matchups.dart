import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';
import 'package:pokedex/features/pokemon/domain/entities/damage_matchups.dart';
import 'package:pokedex/features/pokemon/domain/repositories/type_chart_repository.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_matchups_cubit.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_matchups_state.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_card.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_section_title.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/type_badge.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Texto del multiplicador a partir del porcentaje guardado (RF-DET-06).
/// 400 → ×4, 200 → ×2, 50 → ×½, 25 → ×¼, 0 → ×0.
String matchupMultiplierLabel(int percent) {
  return switch (percent) {
    0 => '×0',
    25 => '×¼',
    50 => '×½',
    200 => '×2',
    400 => '×4',
    // No debería pasar con la tabla real; evita un texto vacío si cambia.
    _ => '×${percent / 100}',
  };
}

/// Sección de matchups: crea su Cubit y dibuja el resultado.
class PokemonDetailMatchups extends StatelessWidget {
  const PokemonDetailMatchups({
    required this.repository,
    required this.defenderTypeIds,
    super.key,
  });

  final TypeChartRepository repository;

  /// Ids de los tipos del Pokémon (1 o 2).
  final List<int> defenderTypeIds;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Si los tipos cambian (p. ej. una restauración), la clave cambia y se
      // crea un Cubit nuevo con los tipos nuevos.
      key: ValueKey(defenderTypeIds.join('-')),
      create: (_) => PokemonMatchupsCubit(
        repository: repository,
        defenderTypeIds: defenderTypeIds,
      ),
      child: const _MatchupsView(),
    );
  }
}

class _MatchupsView extends StatelessWidget {
  const _MatchupsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<PokemonMatchupsCubit, PokemonMatchupsState>(
      builder: (context, state) {
        final matchups = state.matchups;

        // Sin datos todavía: mensaje en vez de grupos vacíos.
        if (matchups.isEmpty) {
          return Text(
            l10n.detailMatchupsEmpty,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MatchupGroup(
              title: l10n.detailMatchupsWeak,
              items: matchups.weaknesses,
              typeNames: state.typeNames,
            ),
            _MatchupGroup(
              title: l10n.detailMatchupsResist,
              items: matchups.resistances,
              typeNames: state.typeNames,
            ),
            _MatchupGroup(
              title: l10n.detailMatchupsImmune,
              items: matchups.immunities,
              typeNames: state.typeNames,
            ),
          ],
        );
      },
    );
  }
}

/// Un grupo (débil, resiste, inmune): subtítulo y sus tarjetas en dos
/// columnas. Si no tiene elementos, no se dibuja (ningún grupo vacío).
class _MatchupGroup extends StatelessWidget {
  const _MatchupGroup({
    required this.title,
    required this.items,
    required this.typeNames,
  });

  final String title;
  final List<TypeMatchup> items;
  final Map<int, String> typeNames;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    // Con el texto muy agrandado, dos columnas no caben: pasa a una.
    final twoColumns = MediaQuery.textScalerOf(context).scale(14) <= 19;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PokemonDetailSectionTitle(title),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 8.0;
              final itemWidth = twoColumns
                  ? (constraints.maxWidth - gap) / 2
                  : constraints.maxWidth;

              // Wrap: cada tarjeta mide medio ancho y baja sola a la fila
              // siguiente.
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final item in items)
                    SizedBox(
                      width: itemWidth,
                      child: _MatchupCard(
                        // Si el nombre aún no está guardado, se muestra el id.
                        typeName: typeNames[item.typeId] ?? '#${item.typeId}',
                        multiplierPercent: item.multiplierPercent,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Tarjeta con el tipo a la izquierda y el multiplicador a la derecha. El
/// multiplicador va en texto, así que el resultado no depende del color
/// (RNF-ACC-05). El ×4 se destaca en amarillo además de decir «×4».
class _MatchupCard extends StatelessWidget {
  const _MatchupCard({required this.typeName, required this.multiplierPercent});

  final String typeName;
  final int multiplierPercent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // MergeSemantics: el lector de pantalla dice «Water ×2» de una vez.
    return MergeSemantics(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: PokemonDetailCard(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: TypeBadge(typeName: typeName)),
              const SizedBox(width: 6),
              Text(
                matchupMultiplierLabel(multiplierPercent),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: multiplierPercent >= 400 ? PixelPalette.accent : null,
                  fontVariations: const [FontVariation('wght', 700)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
