import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_ability.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_extras.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_extras_cubit.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_badge.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_card.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_extras_pending.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_labels.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_section_title.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Habilidades del Pokémon (RF-DET-03): una tarjeta por habilidad con nombre,
/// insignia «Oculta» y efecto resumido. Lee del [PokemonExtrasCubit].
class PokemonDetailAbilities extends StatelessWidget {
  const PokemonDetailAbilities({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final language = Localizations.localeOf(context).languageCode;

    return BlocBuilder<PokemonExtrasCubit, PokemonExtras>(
      builder: (context, extras) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PokemonDetailSectionTitle(l10n.detailAbilitiesTitle),
            if (!extras.downloaded)
              const PokemonDetailExtrasPending()
            else ...[
              if (extras.abilities.isEmpty)
                PokemonDetailCard(child: Text(l10n.detailAbilitiesEmpty)),
              for (var i = 0; i < extras.abilities.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                _AbilityCard(
                  ability: extras.abilities[i],
                  languageCode: language,
                ),
              ],
              // El efecto solo existe en inglés en PokeAPI: se avisa.
              if (language != 'en' && extras.abilities.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    l10n.detailAbilitiesEnglishNote,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}

class _AbilityCard extends StatelessWidget {
  const _AbilityCard({required this.ability, required this.languageCode});

  final PokemonAbility ability;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Si no hay nombre traducido, se muestra el identificador formateado.
    final shown = ability.displayName(languageCode);
    final name = shown == ability.name ? prettifySlug(shown) : shown;

    // MergeSemantics: el lector lo dice como un solo bloque:
    // «Clorofila, Oculta, <efecto>».
    return MergeSemantics(
      child: PokemonDetailCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontVariations: const [FontVariation('wght', 700)],
                  ),
                ),
                if (ability.isHidden)
                  PokemonDetailBadge(l10n.detailAbilityHidden),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              ability.effectSummary ?? l10n.detailAbilityNoEffect,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
