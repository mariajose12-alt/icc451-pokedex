import 'package:pokedex/core/cache/image_cache_manager.dart';

/// ¿Está esta imagen guardada en el teléfono? (sin conexión solo se juega
/// con lo que ya se descargó, PA-10).
abstract interface class TriviaImageCache {
  Future<bool> isCached(String url);
}

/// Consulta la caché persistente de la app (ADR-0009).
class PersistentTriviaImageCache implements TriviaImageCache {
  const PersistentTriviaImageCache();

  @override
  Future<bool> isCached(String url) async {
    // La clave de la caché es la URL, igual que en CachedNetworkImage.
    final info = await ImageCacheManager.instance.getFileFromCache(url);
    // El registro puede existir aunque el archivo ya no (limpieza de caché).
    return info != null && await info.file.exists();
  }
}
