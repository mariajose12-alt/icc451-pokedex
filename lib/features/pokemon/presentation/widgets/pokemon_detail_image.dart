import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/core/cache/image_cache_manager.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_image.dart';

/// Imagen grande del detalle (RF-DET-01).
///  1. Muestra el artwork oficial.
///  2. Mientras carga, o si no se puede cargar (sin conexión y sin la imagen
///     guardada), muestra el sprite de respaldo.
///  3. Si tampoco hay sprite, [PokemonImage] muestra la pokébola.
class PokemonDetailImage extends StatelessWidget {
  const PokemonDetailImage({required this.pokemon, super.key});

  final Pokemon pokemon;

  /// Etiqueta de la animación Hero. Debe ser la MISMA en el catálogo y en el
  /// detalle para que Flutter una las dos imágenes (RF-COM-02).
  static Object heroTag(int pokemonId) => 'pokemon-$pokemonId';

  @override
  Widget build(BuildContext context) {
    // Respaldo: el sprite pequeño, que el catálogo ya descargó.
    final fallback = PokemonImage(
      url: pokemon.spriteUrl,
      iconSize: 96,
      memCacheWidth: 480,
    );

    final artwork = pokemon.artworkUrl;

    // Sin URL del artwork: se usa directamente el respaldo.
    if (artwork == null) {
      return fallback;
    }

    return CachedNetworkImage(
      imageUrl: artwork,
      // Misma caché persistente que el catálogo (ADR-0009).
      cacheManager: ImageCacheManager.instance,
      fit: BoxFit.contain,
      // Se decodifica a un tamaño acorde a la pantalla (RNF-REN-04).
      memCacheWidth: 720,
      // Mientras descarga, se ve el sprite en vez de un círculo de carga.
      placeholder: (context, url) => fallback,
      // Si falla (p. ej. sin conexión y sin guardar), también el sprite.
      errorWidget: (context, url, error) => fallback,
    );
  }
}
