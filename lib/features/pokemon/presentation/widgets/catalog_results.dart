import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/catalog_toolbar.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_bloc.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_event.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/catalog_view_mode_cubit.dart';
import 'package:pokedex/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex/app/router/app_routes.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/catalog_active_filters.dart';

import 'pokemon_card.dart';
import 'pokemon_grid_card.dart';

/// Resultados del catálogo: barra, filtros activos, contador y el listado.
class CatalogResults extends StatefulWidget {
  const CatalogResults({
    required this.pokemon,
    required this.initialText,
    super.key,
  });

  final List<Pokemon> pokemon;

  /// Último criterio de búsqueda guardado, para la barra.
  final String initialText;

  @override
  State<CatalogResults> createState() => _CatalogResultsState();
}

class _CatalogResultsState extends State<CatalogResults> {
  // Un solo controlador para las dos vistas: así se puede leer y mover la
  // posición del scroll al cambiar de una a otra.
  final ScrollController _controller = ScrollController();

  // Ids de los favoritos. Se lee una vez y el stream avisa los cambios.
  Stream<Set<int>>? _favoritos;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _favoritos ??= context.read<FavoritesRepository>().watchFavoriteIds();
  }

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
                // Barra de herramientas: lupa y filtros a la izquierda,
                // selector Cuadrícula/Lista a la derecha.
                CatalogToolbar(
                  initialText: widget.initialText,
                  trailing: SegmentedButton<CatalogViewMode>(
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
                ),
                // Filtros aplicados y aviso de catálogo parcial.
                const CatalogActiveFilters(),
                // Contador debajo de la barra, a la izquierda.
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.pokemonCount(pokemon.length),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  // Se reconstruye cada vez que cambian los favoritos, así las
                  // estrellas se actualizan sin recargar el catálogo.
                  child: StreamBuilder<Set<int>>(
                    stream: _favoritos,
                    initialData: const <int>{},
                    builder: (context, snapshot) {
                      final favoritos = snapshot.data ?? const <int>{};
                      final repository = context.read<FavoritesRepository>();

                      return RefreshIndicator(
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
                                  final item = pokemon[index];
                                  return PokemonGridCard(
                                    pokemon: item,
                                    isFavorite: favoritos.contains(item.id),
                                    // Marcar o quitar desde el catálogo: la base
                                    // avisa y el stream vuelve a dibujar.
                                    onToggleFavorite: () =>
                                        unawaited(repository.toggle(item.id)),
                                    // push: abre el detalle encima y "atrás"
                                    // regresa al catálogo en el mismo punto.
                                    onTap: () => context.push(
                                      AppRoutes.pokemonDetail(item.id),
                                    ),
                                  );
                                },
                              )
                            : ListView.builder(
                                controller: _controller,
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(12),
                                itemCount: pokemon.length,
                                itemBuilder: (context, index) {
                                  final item = pokemon[index];
                                  return PokemonCard(
                                    pokemon: item,
                                    onTap: () => context.push(
                                      AppRoutes.pokemonDetail(item.id),
                                    ),
                                  );
                                },
                              ),
                      );
                    },
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
