import 'dart:async';

import 'package:pokedex/features/pokemon/data/datasources/local/pokemon_local_datasource.dart';
import 'package:pokedex/features/pokemon/data/datasources/remote/pokemon_remote_datasource.dart';

/// Descarga el catálogo completo de PokeAPI a la base local, por páginas.
///
/// Cómo funciona (ADR-0003):
///  1. Lee desde dónde reanudar (cursor por id).
///  2. Pide una página de [pageSize] Pokémon posteriores a ese id.
///  3. Guarda la página y el nuevo cursor en UNA transacción.
///  4. Repite hasta que llega una página incompleta (o vacía).
/// Si algo falla, lo ya guardado se conserva y la próxima vez continúa
/// desde el último cursor. La pantalla nunca se entera de la descarga:
/// solo observa la base de datos.
class CatalogSyncCoordinator {
  CatalogSyncCoordinator({
    required this._remote,
    required this._local,
    this.pageSize = PokemonRemoteDataSource.defaultPageSize,
  });

  final PokemonRemoteDataSource _remote;
  final PokemonLocalDataSource _local;
  final int pageSize;

  // Mientras no sea null hay una sincronización en curso.
  Future<void>? _inFlight;

  final StreamController<bool> _runningController =
      StreamController<bool>.broadcast();

  /// true mientras se descarga. Lo usa el indicador global (IND-07).
  bool get isRunning => _inFlight != null;

  /// Emite true al empezar y false al terminar (con éxito o con error).
  Stream<bool> get runningChanges => _runningController.stream;

  /// Sincroniza el catálogo. Si ya hay una en curso NO inicia otra:
  /// devuelve la misma, así dos pantallas que la pidan a la vez no
  /// duplican las llamadas (la cuota es de 100 por hora).
  /// Lanza la [PokeApiException] original si algo falla; el repositorio
  /// la traduce a un Failure.
  Future<void> sync() {
    final running = _inFlight;
    if (running != null) {
      return running;
    }

    final run = _syncAll().whenComplete(() {
      _inFlight = null;
      _runningController.add(false);
    });
    _inFlight = run;
    _runningController.add(true);
    return run;
  }

  Future<void> _syncAll() async {
    try {
      var cursor = await _local.resumeCursor();

      while (true) {
        final page = await _remote.fetchCatalogPage(
          afterId: cursor,
          pageSize: pageSize,
        );

        // Página vacía: no queda nada después del cursor.
        if (page.items.isEmpty) {
          await _local.markComplete();
          return;
        }

        // Página incompleta: es la última (1025 = 4 × 250 + 25).
        final isLast = page.items.length < pageSize;
        await _local.savePage(page.items, isLast: isLast);
        if (isLast) {
          return;
        }

        cursor = page.items.last.id;
      }
    } catch (_) {
      // Cualquier error (red, API o base de datos) deja el recurso en
      // "failed" conservando el cursor, y se vuelve a lanzar.
      await _markFailedQuietly();
      rethrow;
    }
  }

  Future<void> _markFailedQuietly() async {
    try {
      await _local.markFailed();
    } catch (_) {
      // Si ni siquiera se puede escribir el estado, se prioriza mostrar
      // el error original.
    }
  }
}
