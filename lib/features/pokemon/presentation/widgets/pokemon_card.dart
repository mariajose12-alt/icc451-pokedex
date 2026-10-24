import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';

import 'type_badge.dart';

/// Tarjeta de un Pokémon en el catálogo: imagen, número, nombre y tipos.
class PokemonCard extends StatelessWidget {
  const PokemonCard({required this.pokemon, required this.onTap, super.key});

  final Pokemon pokemon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
    final spokenLabel =
        '$name, Pokédex número ${pokemon.nationalDexNumber}, '
        'tipos: ${typeNames.join(', ')}';

    // Imagen oficial; si no existe, el sprite; si tampoco, el icono de respaldo.
    final imageUrl = pokemon.artworkUrl ?? pokemon.spriteUrl;

    return Semantics(
      button: true,
      onTap: onTap,
      label: spokenLabel,
      excludeSemantics: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: imageUrl == null
                      ? const Icon(Icons.catching_pokemon, size: 40)
                      : CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          // Decodifica a un tamaño acorde al contenedor (RNF-REN-04).
                          memCacheWidth: 240,
                          placeholder: (context, url) => const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.catching_pokemon, size: 40),
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
                        ),
                      ),
                      Text(name, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
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
        ),
      ),
    );
  }
}
