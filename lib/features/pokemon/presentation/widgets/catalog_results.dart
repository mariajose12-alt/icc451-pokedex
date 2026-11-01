import 'dart:async';

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
class CatalogResults extends StatefulWidget {
  const CatalogResults({required this.pokemon, super.key});

  final List<Pokemon> pokemon;

  @override
  State<CatalogResults> createState() => _CatalogResultsState();
}

class _CatalogResultsState extends State<CatalogResults> {
  // Un solo controlador para las dos vistas: así se puede leer y mover la
  // posición del scroll al cambiar de una a otra.
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Cambia de vista conservando por dónde ibas.
  /// Ambas vistas tienen elementos del mismo tamaño, así que la posición
  /// equivale a una fracción de la lista (0 = inicio, 1 = final). Esa misma
  /// fracción en la vista nueva cae en el mismo Pokémon, con poca diferencia.
  void _changeMode(CatalogViewMode mode) {
    // 1. Antes de cambiar: qué fracción de la lista se ha recorrido.
    var fraction = 0.0;
    if (_controller.hasClients) {
      final position = _controller.position;
      if (position.maxScrollExtent > 0) {
        fraction = position.pixels / position.maxScrollExtent;
      }
    }

    // 2. Cambiar la vista.
    unawaited(context.read<CatalogViewModeCubit>().select(mode));

    // 3. Cuando la vista nueva esté dibujada, saltar a la misma fracción.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) {
        return;
      }
      final max = _controller.position.maxScrollExtent;
      _controller.jumpTo((fraction * max).clamp(0.0, max));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final pokemon = widget.pokemon;

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
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    children: [
                      // Contador a la izquierda.
                      Expanded(
                        child: Text(
                          l10n.pokemonCount(pokemon.length),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      // Selector a la derecha: solo iconos. El texto queda
                      // como tooltip y como etiqueta para lectores de pantalla.
                      SegmentedButton<CatalogViewMode>(
                        showSelectedIcon: false,
                        style: const ButtonStyle(
                          // Objetivo táctil de 48 dp (RNF-ACC-03).
                          minimumSize: WidgetStatePropertyAll(Size(48, 48)),
                        ),
                        segments: [
                          ButtonSegment<CatalogViewMode>(
                            value: CatalogViewMode.grid,
                            icon: const Icon(Icons.grid_view),
                            tooltip: l10n.viewGrid,
                          ),
                          ButtonSegment<CatalogViewMode>(
                            value: CatalogViewMode.list,
                            icon: const Icon(Icons.view_list),
                            tooltip: l10n.viewList,
                          ),
                        ],
                        selected: <CatalogViewMode>{mode},
                        onSelectionChanged: (selection) {
                          _changeMode(selection.first);
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
                            controller: _controller,
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
                            controller: _controller,
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
