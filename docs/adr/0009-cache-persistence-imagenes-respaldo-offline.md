# ADR-0009: Caché persistente de imágenes con respaldo offline

- **Estado:** Aceptado
- **Fecha de decisión:** 2026-10-26
- **Fecha de verificación:** 2026-10-28
- **Decidido por:** Almy y María

## Contexto

Las imágenes oficiales de cada Pokémon se muestran en el catálogo y en el detalle (RF-CAT-01, RF-DET-01). El enunciado exige que las imágenes ya almacenadas se vean sin conexión y que las no disponibles se sustituyan por un recurso de respaldo sin errores (OF-08, PA-10). También pide que la persistencia de imágenes tenga un límite de espacio y una política de limpieza (PS-08), y que la memoria se use de forma responsable (RNF-REN-04).

`flutter_cache_manager` 3.4.5 guarda por defecto los archivos en la carpeta temporal de la app, y su documentación advierte que el sistema operativo puede borrarlos en cualquier momento. Eso no cumple PA-10. Además, dos `CacheManager` con la misma clave interfieren entre sí, por lo que debe existir una sola instancia.

La tabla `pokemons` ya tiene `artworkUrl` (la URL remota) y `artworkLocalPath` (la ruta local descargada), según ADR-0006.

## Decisión

1. **Un único `CacheManager` propio**, creado con `Config` en `lib/core/cache/image_cache_manager.dart`, con clave fija (`pokedexImages`). Como el sistema de archivos por defecto (`IOFileSystem`) usa la carpeta temporal, se implementa una clase `_PersistentFileSystem` que crea los archivos con `LocalFileSystem` del paquete `file` dentro de la carpeta de documentos de la app.
2. **Límites explícitos:** `maxNrOfCacheObjects` (300) y `stalePeriod` (30 días) se definen en `Config`, en un solo lugar, y se documentan en el README (PS-08).
3. **Widgets con `cached_network_image`** que usan ese `CacheManager` y muestran una imagen de respaldo si la descarga falla o no hay conexión (OF-08). Se conectan en T-017.
4. **Imagen de respaldo** en `assets/images/dados.png`, usada cuando no hay imagen local ni remota disponible.
5. **Registro de la ruta local:** después de descargar una imagen, la ruta se guarda en `artworkLocalPath` mediante `saveArtworkLocalPath` del DAO, para que la UI la encuentre sin volver a la red.
6. **Solo se descargan imágenes al mostrarlas.** No se descarga el catálogo completo de imágenes en la primera ejecución (§4.1 y PS-02).

## Alternativas consideradas

1. **`Image.network` sin caché.** Simple, pero no funciona sin conexión y vuelve a descargar cada imagen al reabrir la pantalla.
2. **Usar el `DefaultCacheManager`.** Ya viene configurado, pero guarda en la carpeta temporal, lo que incumple PA-10. Se descartó.
3. **Guardar las imágenes como BLOB en SQLite.** Mantiene todo en un solo archivo, pero infla la base de datos y ralentiza las consultas del catálogo.
4. **Descargar todas las imágenes durante la sincronización.** Garantiza disponibilidad offline completa, pero son 1025 descargas en la primera ejecución, y el enunciado no lo exige (PS-02).
5. **Caché solo en memoria.** Se pierde al cerrar la app, lo que incumple OF-10 y PA-10.

## Verificación

Prueba realizada en dispositivo Samsung SM-A556E (Android 16, API 36):

1. Descarga con `ImageCacheManager.instance.getSingleFile(url)`. El archivo se guardó en `/data/user/0/java.edu.pucmm.pokedex/app_flutter/pokedexImages/`, y `existsSync()` devolvió `true`.
2. Reinicio de la app (hot restart), sin nueva descarga.
3. `getFileFromCache(url)` devolvió la misma ruta y `Existe en caché: true`.

Con esto se cumple PA-10: el archivo persiste en la carpeta de documentos y se recupera después de reiniciar, sin depender de la carpeta temporal.

## Consecuencias

**A favor**
- Las imágenes vistas siguen disponibles después de reiniciar la app (PA-10), verificado en dispositivo.
- El espacio ocupado está acotado por `maxNrOfCacheObjects` y `stalePeriod`, y puede verificarse en la demostración.
- La sincronización no descarga imágenes, así que no bloquea el arranque (OF-03).

**En contra**
- Un Pokémon nunca visto sin conexión muestra la imagen de respaldo, no su arte oficial (comportamiento esperado por OF-08).
- `artworkLocalPath` puede apuntar a un archivo que ya no existe, si la caché se limpió por política de tamaño o vigencia. La UI debe tratar ese caso como imagen no disponible.

**Pendiente**
- Confirmar los valores de `maxNrOfCacheObjects` y `stalePeriod`.
- Widgets con imagen de respaldo (OF-08), en T-017.
- Se agregan dos dependencias que deben justificarse en el README (RNF-MAN-04): `file`, para implementar el sistema de archivos propio, y `sqflite`, que `flutter_cache_manager` usa para sus metadatos.


**Requisitos relacionados:** RF-CAT-01, RF-DET-01, OF-03, OF-08, OF-10, PS-02, PS-08, RNF-MAN-04, RNF-REN-04, PA-10, ADR-0006.