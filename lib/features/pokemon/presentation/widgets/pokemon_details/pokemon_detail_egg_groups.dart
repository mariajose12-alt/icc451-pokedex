import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_extras.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_extras_cubit.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_card.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_labels.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Grupos de huevo (RF-DET-07): una tarjeta ancha, como en el diseño:
/// «Grupos huevo ........ Monstruo · Dragón». No se dibuja mientras no haya
/// datos: el aviso de «se descargan al abrir» ya lo muestra Habilidades.
class PokemonDetailEggGroups extends StatelessWidget {
  const PokemonDetailEggGroups({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<PokemonExtrasCubit, PokemonExtras>(
      builder: (context, extras) {
        if (extras.eggGroups.isEmpty) {
          return const SizedBox.shrink();
        }

        final labels = [
          for (final slug in extras.eggGroups) eggGroupLabel(l10n, slug),
        ];

        // Un solo bloque para el lector: «Grupos huevo: Monstruo, Dragón».
        return Semantics(
          container: true,
          label: '${l10n.detailEggGroupsTitle}: ${labels.join(', ')}',
          excludeSemantics: true,
          child: PokemonDetailCard(
            // Wrap: si el texto es grande, el valor baja a otra línea.
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  l10n.detailEggGroupsTitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  labels.join(' · '),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontVariations: const [FontVariation('wght', 700)],
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
