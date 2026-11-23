import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/core/cache/image_cache_manager.dart';

/// Imagen de un Pokémon con caché persistente y respaldo.
///  - Primero busca el archivo en la caché del disco (funciona sin conexión).
///  - Si no está, lo descarga y lo guarda ahí.
///  - Si no hay URL o la descarga falla, muestra la pokébola, sin errores.
class PokemonImage extends StatelessWidget {
  const PokemonImage({
    required this.url,
    required this.iconSize,
    required this.memCacheWidth,
    super.key,
  });

  /// URL de la imagen. Puede ser null si el Pokémon no tiene.
  final String? url;

  /// Tamaño de la pokébola de respaldo.
  final double iconSize;

  /// Ancho al que se decodifica la imagen (RNF-REN-04).
  final int memCacheWidth;

  @override
  Widget build(BuildContext context) {
    final imageUrl = url;
    if (imageUrl == null) {
      return Icon(Icons.catching_pokemon, size: iconSize);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      // Caché en la carpeta de documentos (ADR-0009), no en la temporal.
      cacheManager: ImageCacheManager.instance,
      fit: BoxFit.contain,
      // Mantiene nítido el pixel art.
      filterQuality: FilterQuality.none,
      memCacheWidth: memCacheWidth,
      placeholder: (context, url) => const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      // Sin conexión y sin la imagen guardada: la pokébola de siempre.
      errorWidget: (context, url, error) =>
          Icon(Icons.catching_pokemon, size: iconSize),
    );
  }
}
