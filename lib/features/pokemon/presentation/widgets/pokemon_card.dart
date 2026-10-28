import 'package:flutter/material.dart';
import 'package:pokedex/core/widgets/pixel_panel.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_image.dart';
import 'package:pokedex/l10n/app_localizations.dart';

import 'type_badge.dart';

/// Tarjeta del Pokémon en modo lista: sprite a la izquierda y datos a la derecha.
class PokemonCard extends StatelessWidget {
  const PokemonCard({required this.pokemon, required this.onTap, super.key});

  final Pokemon pokemon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Textos que se muestran.
    final number = '#${pokemon.nationalDexNumber.toString().padLeft(3, '0')}';
    final name = pokemon.name.isEmpty
        ? pokemon.name
        : pokemon.name[0].toUpperCase() + pokemon.name.substring(1);

    // Etiqueta para lectores de pantalla.
    final typeNames = <String>[];
    for (final type in pokemon.types) {
      typeNames.add(type.name);
    }
    final spokenLabel = l10n.pokemonSemanticLabel(
      name,
      pokemon.nationalDexNumber,
      typeNames.join(', '),
    );

    // En el listado se usa el sprite pequeño (descarga mucho menos y cabe todo
    // el catálogo offline); el artwork oficial se reserva para el detalle.
    final imageUrl = pokemon.spriteUrl ?? pokemon.artworkUrl;

    return Semantics(
      button: true,
      onTap: onTap,
      label: spokenLabel,
      excludeSemantics: true,
      child: PixelPanel(
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: PokemonImage(
                url: imageUrl,
                iconSize: 40,
                memCacheWidth: 240,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    number,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontVariations: const [FontVariation('wght', 700)],
                    ),
                  ),
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontVariations: const [FontVariation('wght', 700)],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (final type in pokemon.types)
                        TypeBadge(typeName: type.name),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
