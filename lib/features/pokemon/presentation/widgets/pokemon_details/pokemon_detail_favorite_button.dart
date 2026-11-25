import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:pokedex/features/favorites/presentation/widgets/favorite_heart_button.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Botón de favorito sobre la esquina de la imagen (RF-DET-10, RF-COM-03).
/// Necesita un [FavoriteCubit] arriba en el árbol.
class PokemonDetailFavoriteButton extends StatelessWidget {
  const PokemonDetailFavoriteButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<FavoriteCubit, bool>(
      builder: (context, isFavorite) => FavoriteHeartButton(
        isFavorite: isFavorite,
        label: isFavorite ? l10n.detailFavoriteRemove : l10n.detailFavoriteAdd,
        onPressed: () => context.read<FavoriteCubit>().toggle(),
      ),
    );
  }
}
