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
///
/// Si [overrideImage] es true (otra forma o shiny), usa [artworkUrl] y
/// [spriteUrl] en lugar de las del [pokemon].
class PokemonDetailImage extends StatelessWidget {
  const PokemonDetailImage({
    required this.pokemon,
    this.overrideImage = false,
    this.artworkUrl,
    this.spriteUrl,
    super.key,
  });

  final Pokemon pokemon;
  final bool overrideImage;
  final String? artworkUrl;
  final String? spriteUrl;

  /// Etiqueta de la animación Hero. Debe ser la MISMA en el catálogo y en el
  /// detalle para que Flutter una las dos imágenes (RF-COM-02).
  static Object heroTag(int pokemonId) => 'pokemon-$pokemonId';

  @override
  Widget build(BuildContext context) {
    final sprite = overrideImage ? spriteUrl : pokemon.spriteUrl;
    final artwork = overrideImage ? artworkUrl : pokemon.artworkUrl;

    // Respaldo: el sprite pequeño, que el catálogo ya descargó.
    final fallback = PokemonImage(
      url: sprite,
      iconSize: 96,
      memCacheWidth: 480,
    );

    // Sin URL del artwork: se usa directamente el respaldo.
    if (artwork == null) {
      return fallback;
    }

    return CachedNetworkImage(
      // La clave hace que al cambiar de forma se cargue la imagen nueva.
      key: ValueKey(artwork),
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
