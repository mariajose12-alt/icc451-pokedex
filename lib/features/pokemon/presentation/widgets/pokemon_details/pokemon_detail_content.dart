import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/core/widgets/pixel_panel.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_detail_repository.dart';
import 'package:pokedex/features/pokemon/domain/repositories/type_chart_repository.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_moves_repository.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_extras_cubit.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_abilities.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_egg_groups.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_header.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_matchups.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_metrics.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_pending_section.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_stats.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_stats_radar.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_tab.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_tab_bar.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_evolution.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_section_title.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_moves_cubit.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_moves.dart';
import 'package:pokedex/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:pokedex/features/favorites/presentation/cubit/favorite_cubit.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Contenido del detalle cuando el Pokémon está guardado: header, pestañas y
/// el contenido de la pestaña elegida.
///
/// Es StatefulWidget solo para recordar la pestaña elegida: es estado de
/// interfaz que no se guarda ni lo necesita otra pantalla.
class PokemonDetailContent extends StatefulWidget {
  const PokemonDetailContent({
    required this.pokemon,
    this.typeChartRepository,
    this.detailRepository,
    this.onOpenPokemon,
    this.movesRepository,
    this.favoritesRepository,
    super.key,
  });

  final Pokemon pokemon;

  /// Tabla de efectividades. Si es null, la pestaña Combate queda vacía.
  final TypeChartRepository? typeChartRepository;

  /// Habilidades, egg groups, evoluciones y formas. Si es null, esas secciones
  /// no se muestran (así las pruebas viejas siguen funcionando).
  final PokemonDetailRepository? detailRepository;

  /// Movimientos de la pestaña Movs. Si es null, esa pestaña muestra el
  /// aviso de «próximamente» (así las pruebas viejas siguen igual).
  final PokemonMovesRepository? movesRepository;

  /// Favoritos. Si es null, el detalle no muestra el corazón (así las
  /// pruebas viejas siguen igual).
  final FavoritesRepository? favoritesRepository;

  /// Se llama con el id de una especie de la cadena evolutiva. Lo da la
  /// página, que sabe navegar.
  final ValueChanged<int>? onOpenPokemon;

  @override
  State<PokemonDetailContent> createState() => _PokemonDetailContentState();
}

class _PokemonDetailContentState extends State<PokemonDetailContent> {
  PokemonDetailTab _tab = PokemonDetailTab.summary;

  @override
  Widget build(BuildContext context) {
    // Alto de la barra de pestañas: 48 como mínimo y más si el texto del
    // sistema está agrandado (RNF-ACC-04).
    final textHeight = MediaQuery.textScalerOf(context).scale(14);
    final tabBarHeight = math.max(48.0, textHeight * 1.4 + 24);

    // Una sola lista que se desplaza: el header sube y la barra de pestañas
    // se queda fija arriba (pinned) mientras baja el contenido.
    final scroll = CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: PokemonDetailHeader(
            pokemon: widget.pokemon,
            hasExtras: widget.detailRepository != null,
            typeChartRepository: widget.typeChartRepository,
            hasFavorites: widget.favoritesRepository != null,
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _PinnedTabBarDelegate(
            height: tabBarHeight,
            child: PokemonDetailTabBar(
              selected: _tab,
              onSelected: (tab) => setState(() => _tab = tab),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          sliver: _tabContent(),
        ),
      ],
    );

    // Los Cubits envuelven TODAS las pestañas: cambiar de pestaña no vuelve a
    // leer la base ni pierde la versión elegida en Movs. La key hace que se
    // creen nuevos si cambia el Pokémon.
    Widget result = scroll;

    final movesRepository = widget.movesRepository;
    if (movesRepository != null) {
      result = BlocProvider<PokemonMovesCubit>(
        key: ValueKey('moves-${widget.pokemon.id}'),
        create: (context) => PokemonMovesCubit(
          repository: movesRepository,
          pokemonId: widget.pokemon.id,
        ),
        child: result,
      );
    }

    final detailRepository = widget.detailRepository;
    if (detailRepository != null) {
      result = BlocProvider<PokemonExtrasCubit>(
        key: ValueKey(widget.pokemon.id),
        create: (context) => PokemonExtrasCubit(
          repository: detailRepository,
          pokemonId: widget.pokemon.id,
        ),
        child: result,
      );
    }

    final favoritesRepository = widget.favoritesRepository;
    if (favoritesRepository != null) {
      result = BlocProvider<FavoriteCubit>(
        key: ValueKey('fav-${widget.pokemon.id}'),
        create: (context) => FavoriteCubit(
          repository: favoritesRepository,
          pokemonId: widget.pokemon.id,
        ),
        child: result,
      );
    }

    return result;
  }

  /// Contenido (como sliver) de la pestaña elegida.
  Widget _tabContent() {
    return switch (_tab) {
      PokemonDetailTab.summary => SliverToBoxAdapter(
        child: _SummaryTab(
          pokemon: widget.pokemon,
          showExtras: widget.detailRepository != null,
        ),
      ),
      PokemonDetailTab.evolution => SliverToBoxAdapter(
        child: widget.detailRepository == null
            ? const PokemonDetailPendingSection()
            : PokemonDetailEvolution(
                currentSpeciesId: widget.pokemon.id,
                onOpenPokemon: widget.onOpenPokemon,
              ),
      ),
      PokemonDetailTab.combat => SliverToBoxAdapter(child: _combatTab()),
      PokemonDetailTab.moves =>
        widget.movesRepository == null
            ? const SliverToBoxAdapter(child: PokemonDetailPendingSection())
            : const PokemonDetailMoves(),
    };
  }

  Widget _combatTab() {
    final chartRepository = widget.typeChartRepository;
    if (chartRepository == null) {
      return const SizedBox.shrink();
    }
    return PokemonDetailMatchups(
      repository: chartRepository,
      defenderTypeIds: [for (final type in widget.pokemon.types) type.id],
    );
  }
}

/// Pestaña Resumen: stats base (RF-DET-02), habilidades (RF-DET-03) y datos
/// con peso, altura y egg groups (RF-DET-07).
class _SummaryTab extends StatelessWidget {
  const _SummaryTab({required this.pokemon, required this.showExtras});

  final Pokemon pokemon;

  /// ¿Hay repositorio del detalle? Si no, no se muestran habilidades ni egg
  /// groups.
  final bool showExtras;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PixelPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PokemonDetailStatsRadar(stats: pokemon.stats),
              const SizedBox(height: 16),
              PokemonDetailStats(
                stats: pokemon.stats,
                total: pokemon.totalStats,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PokemonDetailSectionTitle(l10n.detailDataTitle),
        PokemonDetailMetrics(
          heightDecimeters: pokemon.height,
          weightHectograms: pokemon.weight,
        ),
        if (showExtras) ...[
          const SizedBox(height: 8),
          const PokemonDetailEggGroups(),
          const SizedBox(height: 16),
          const PokemonDetailAbilities(),
        ],
      ],
    );
  }
}

/// Mantiene la barra de pestañas fija arriba al desplazar. Altura constante:
/// mínimo y máximo iguales, así no se encoge.
class _PinnedTabBarDelegate extends SliverPersistentHeaderDelegate {
  _PinnedTabBarDelegate({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: height, child: child);
  }

  @override
  bool shouldRebuild(covariant _PinnedTabBarDelegate oldDelegate) {
    // El hijo es nuevo en cada build; si no se reconstruyera, la pestaña
    // elegida no cambiaría de color.
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
