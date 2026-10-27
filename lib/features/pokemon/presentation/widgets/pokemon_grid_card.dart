import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';
import 'package:pokedex/core/widgets/pixel_panel.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/l10n/app_localizations.dart';

import 'type_badge.dart';

/// Tarjeta del Pokémon en modo cuadrícula: sprite grande arriba y datos debajo.
class PokemonGridCard extends StatelessWidget {
  const PokemonGridCard({
    required this.pokemon,
    required this.onTap,
    this.isFavorite = false,
    this.onToggleFavorite,
    super.key,
  });

  final Pokemon pokemon;
  final VoidCallback onTap;
  final bool isFavorite;

  /// Si es null (todavía no existen los favoritos), no se muestra la estrella.
  final VoidCallback? onToggleFavorite;

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

    final imageUrl = pokemon.spriteUrl ?? pokemon.artworkUrl;
    final favoriteCallback = onToggleFavorite;

    return PixelPanel(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // El texto va en un bloque aparte para que la estrella siga siendo
          // un botón independiente para los lectores de pantalla.
          Semantics(
            button: true,
            label: spokenLabel,
            excludeSemantics: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 112,
                  width: double.infinity,
                  child: imageUrl == null
                      ? const Icon(Icons.catching_pokemon, size: 56)
                      : CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          // Mantiene nítido el pixel art.
                          filterQuality: FilterQuality.none,
                          memCacheWidth: 320,
                          placeholder: (context, url) => const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.catching_pokemon, size: 56),
                        ),
                ),
                const SizedBox(height: 6),
                Text(
                  number,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontVariations: const [FontVariation('wght', 700)],
                  ),
                ),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontVariations: const [FontVariation('wght', 700)],
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  alignment: WrapAlignment.center,
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
          if (favoriteCallback != null)
            Positioned(
              top: -8,
              right: -8,
              child: IconButton(
                onPressed: favoriteCallback,
                color: PixelPalette.accent,
                icon: Icon(isFavorite ? Icons.star : Icons.star_border),
              ),
            ),
        ],
      ),
    );
  }
}
