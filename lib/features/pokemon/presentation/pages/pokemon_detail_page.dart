import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_detail_cubit.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_detail_state.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/catalog_message_view.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_content.dart';
import 'package:pokedex/l10n/app_localizations.dart';
import 'package:pokedex/features/pokemon/domain/repositories/type_chart_repository.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_detail_repository.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_moves_repository.dart';

/// Pantalla de detalle. Solo conoce el Cubit: nunca la red ni la base.
/// El Cubit lo crea la ruta (sección 4).
class PokemonDetailPage extends StatelessWidget {
  const PokemonDetailPage({
    this.typeChartRepository,
    this.detailRepository,
    this.movesRepository,
    super.key,
  });

  final TypeChartRepository? typeChartRepository;

  /// Se lo da el router. Opcional para poder probar la pantalla sin él.
  final PokemonDetailRepository? detailRepository;

  /// Se lo da el router. Opcional para poder probar la pantalla sin él.
  final PokemonMovesRepository? movesRepository;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: BlocBuilder<PokemonDetailCubit, PokemonDetailState>(
        builder: (context, state) {
          // switch sobre una clase sellada: el compilador avisa si falta
          // algún estado.
          return switch (state) {
            PokemonDetailLoading() => Center(
              child: CircularProgressIndicator(semanticsLabel: l10n.loading),
            ),
            PokemonDetailNotFound() => CatalogMessageView(
              icon: Icons.search_off,
              title: l10n.detailNotFoundTitle,
              message: l10n.detailNotFoundMessage,
              actionLabel: l10n.detailBack,
              onAction: () => context.pop(),
            ),
            PokemonDetailSuccess(:final pokemon) => PokemonDetailContent(
              pokemon: pokemon,
              typeChartRepository: typeChartRepository,
              detailRepository: detailRepository,
              movesRepository: movesRepository,
              onOpenPokemon: (id) => context.push('/pokemon/$id'),
            ),
          };
        },
      ),
    );
  }
}
