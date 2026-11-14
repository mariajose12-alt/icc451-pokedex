import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_detail_cubit.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_detail_state.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/catalog_message_view.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_detail_content.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Pantalla de detalle. Solo conoce el Cubit: nunca la red ni la base.
/// El Cubit lo crea la ruta (sección 4).
class PokemonDetailPage extends StatelessWidget {
  const PokemonDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      // La flecha de regreso aparece sola porque la pantalla se abre
      // encima del catálogo.
      appBar: AppBar(),
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
            ),
          };
        },
      ),
    );
  }
}