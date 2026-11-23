import 'package:file/file.dart' show Directory, File;
import 'package:file/local.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Clave única del caché. Dos managers con la misma clave interfieren entre sí.
const _cacheKey = 'pokedexImages';

/// Guarda los archivos en la carpeta de documentos de la app, que el sistema
/// no borra por su cuenta (PA-10). El valor por defecto usa la carpeta temporal.
class _PersistentFileSystem implements FileSystem {
  _PersistentFileSystem(this._key);

  final String _key;
  final LocalFileSystem _sistemaLocal = LocalFileSystem();
  Directory? _carpeta;

  Future<Directory> _obtenerCarpeta() async {
    final existente = _carpeta;
    if (existente != null) return existente;

    final documentos = await getApplicationDocumentsDirectory();
    final carpeta = _sistemaLocal.directory(p.join(documentos.path, _key));
    await carpeta.create(recursive: true);
    _carpeta = carpeta;
    return carpeta;
  }

  @override
  Future<File> createFile(String name) async {
    final carpeta = await _obtenerCarpeta();
    return _sistemaLocal.file(p.join(carpeta.path, name));
  }
}

/// Un único CacheManager para toda la app. Lo usan los widgets de imagen.
abstract final class ImageCacheManager {
  static final CacheManager instance = CacheManager(
    Config(
      _cacheKey,
      // Valores propuestos, pendientes de acuerdo con María (ADR-0009).
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 300,
      repo: JsonCacheInfoRepository(databaseName: _cacheKey),
      fileSystem: _PersistentFileSystem(_cacheKey),
      fileService: HttpFileService(),
    ),
  );
}
