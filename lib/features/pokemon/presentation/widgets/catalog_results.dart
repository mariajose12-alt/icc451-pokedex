import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_bloc.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_event.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/catalog_view_mode_cubit.dart';
import 'package:pokedex/l10n/app_localizations.dart';

import 'pokemon_card.dart';
import 'pokemon_grid_card.dart';

/// Resultados del catálogo: contador, selector Cuadrícula/Lista y el listado.
class CatalogResults extends StatelessWidget {
  const CatalogResults({required this.pokemon, super.key});

  final List<Pokemon> pokemon;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    return BlocBuilder<CatalogViewModeCubit, CatalogViewMode>(
      builder: (context, mode) {
        // Con el texto muy grande la cuadrícula no cabe: se usa la lista
        // automáticamente (RNF-ACC-04).
        final showGrid = mode == CatalogViewMode.grid && textScale <= 1.3;

        return Center(
          child: ConstrainedBox(
            // En pantallas anchas el contenido no se estira (RF-CAT-06).
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Text(
                        l10n.pokemonCount(pokemon.length),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SegmentedButton<CatalogViewMode>(
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment<CatalogViewMode>(
                            value: CatalogViewMode.grid,
                            icon: const Icon(Icons.grid_view),
                            label: Text(l10n.viewGrid),
                          ),
                          ButtonSegment<CatalogViewMode>(
                            value: CatalogViewMode.list,
                            icon: const Icon(Icons.view_list),
                            label: Text(l10n.viewList),
                          ),
                        ],
                        selected: <CatalogViewMode>{mode},
                        onSelectionChanged: (selection) {
                          context.read<CatalogViewModeCubit>().select(
                            selection.first,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<CatalogBloc>().add(
                        const CatalogRefreshRequested(),
                      );
                    },
                    // Ambas formas construyen sus elementos de forma diferida
                    // (RNF-REN-01).
                    child: showGrid
                        ? GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(12),
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 220,
                                  mainAxisExtent: 290 * textScale,
                                  crossAxisSpacing: 4,
                                  mainAxisSpacing: 4,
                                ),
                            itemCount: pokemon.length,
                            itemBuilder: (context, index) {
                              return PokemonGridCard(
                                pokemon: pokemon[index],
                                onTap: () {},
                              );
                            },
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(12),
                            itemCount: pokemon.length,
                            itemBuilder: (context, index) {
                              return PokemonCard(
                                pokemon: pokemon[index],
                                onTap: () {},
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
