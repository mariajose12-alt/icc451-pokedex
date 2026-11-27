import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex/app/router/app_routes.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';
import 'package:pokedex/core/widgets/pixel_sprite.dart';
import 'package:pokedex/features/favorites/presentation/cubit/favorites_list_cubit.dart';
import 'package:pokedex/features/favorites/presentation/cubit/favorites_list_state.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_grid_card.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Pantalla de favoritos (RF-FAV-02). Solo dibuja lo que dice el cubit,
/// y el cubit lee de la base local: funciona sin conexión (RF-FAV-03).
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<FavoritesListCubit, FavoritesListState>(
        builder: (context, state) => switch (state) {
          FavoritesListLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          FavoritesListEmpty() => const _EmptyView(),
          FavoritesListLoaded() => _FavoritesGrid(state: state),
        },
      ),
    );
  }
}

/// Estado vacío (PA-15): explica qué pasa y sugiere qué hacer.
/// Se puede desplazar para no desbordarse con texto grande.
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Decorativo: el título ya dice lo mismo.
            ExcludeSemantics(
              child: PixelSprite(
                sprite: PixelSprites.heart,
                color: PixelPalette.textMuted,
                width: 72,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.favoritesEmptyTitle,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.favoritesEmptyMessage,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // go: cambia a la pestaña del Pokédex.
            FilledButton(
              onPressed: () => context.go(AppRoutes.catalog),
              child: Text(l10n.favoritesEmptyAction),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesGrid extends StatelessWidget {
  const _FavoritesGrid({required this.state});

  final FavoritesListLoaded state;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    // Con el texto muy grande la cuadrícula no cabe: una sola columna.
    final oneColumn = textScale > 1.3;
    final items = state.items;

    return Center(
      child: ConstrainedBox(
        // En pantallas anchas el contenido no se estira.
        constraints: const BoxConstraints(maxWidth: 720),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _Header(count: items.length, sort: state.sort),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              // Los elementos se construyen de forma diferida (RNF-REN-01).
              sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: oneColumn ? 720 : 220,
                  mainAxisExtent: 290 * textScale,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return PokemonGridCard(
                    // La clave evita que Flutter confunda tarjetas al
                    // reordenar o quitar.
                    key: ValueKey(item.id),
                    pokemon: item,
                    isFavorite: true,
                    // push: el detalle se abre encima y "atrás" regresa aquí.
                    onTap: () => context.push(AppRoutes.pokemonDetail(item.id)),
                    onToggleFavorite: () => _remove(context, item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quita el favorito y ofrece deshacer. La tarjeta desaparece cuando la
/// base avisa, no por una actualización manual (OF-16, OF-17).
void _remove(BuildContext context, Pokemon pokemon) {
  final cubit = context.read<FavoritesListCubit>();
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context)!;
  final name = pokemon.name.isEmpty
      ? pokemon.name
      : pokemon.name[0].toUpperCase() + pokemon.name.substring(1);

  unawaited(cubit.remove(pokemon.id));
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(l10n.favoritesRemovedSnack(name)),
        action: SnackBarAction(
          label: l10n.favoritesUndo,
          onPressed: () => unawaited(cubit.undoRemove(pokemon.id)),
        ),
      ),
    );
}

class _Header extends StatelessWidget {
  const _Header({required this.count, required this.sort});

  final int count;
  final FavoritesSort sort;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<FavoritesListCubit>();

    final options = <(FavoritesSort, String)>[
      (FavoritesSort.recent, l10n.favoritesSortRecent),
      (FavoritesSort.name, l10n.favoritesSortName),
      (FavoritesSort.number, l10n.favoritesSortNumber),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Semantics(
                  header: true,
                  child: Text(
                    l10n.navFavorites,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontVariations: const [FontVariation('wght', 700)],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Contador: texto oscuro sobre amarillo (contraste alto).
              DecoratedBox(
                decoration: const BoxDecoration(color: PixelPalette.accent),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  child: Text(
                    '$count',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: PixelPalette.background,
                      fontVariations: const [FontVariation('wght', 700)],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.favoritesSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: PixelPalette.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.favoritesSortLabel,
            style: theme.textTheme.labelMedium?.copyWith(
              color: PixelPalette.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          // Wrap: con texto grande los chips bajan de línea en vez de
          // cortarse. El elegido lleva check: no depende solo del color.
          Wrap(
            spacing: 8,
            children: [
              for (final (value, label) in options)
                ChoiceChip(
                  label: Text(label),
                  selected: sort == value,
                  onSelected: (_) => cubit.selectSort(value),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
