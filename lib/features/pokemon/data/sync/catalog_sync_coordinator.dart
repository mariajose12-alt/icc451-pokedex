import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pokedex/core/network/network_exceptions.dart';
import 'package:pokedex/features/pokemon/data/datasources/local/pokemon_local_datasource.dart';
import 'package:pokedex/features/pokemon/data/datasources/remote/pokemon_remote_datasource.dart';
import 'package:pokedex/features/pokemon/data/models/pokemon_dto.dart';

/// Descarga el catálogo completo de PokeAPI a la base local, por páginas.
///
/// Cómo funciona (ADR-0003):
///  1. Lee desde dónde reanudar (cursor por id).
///  2. Pide una página de [pageSize] Pokémon posteriores a ese id.
///     Si falla por algo pasajero, la repite con espera creciente (backoff).
///  3. Guarda la página y el nuevo cursor en UNA transacción.
///  4. Repite hasta que llega una página incompleta (o vacía).
/// Si algo falla de forma definitiva, lo ya guardado se conserva y la próxima
/// vez continúa desde el último cursor. La pantalla nunca se entera de la
/// descarga: solo observa la base de datos.
class CatalogSyncCoordinator {
  CatalogSyncCoordinator({
    required this._remote,
    required this._local,
    this.pageSize = PokemonRemoteDataSource.defaultPageSize,
    this.retryDelays = defaultRetryDelays,
  });

  /// Esperas antes de cada reintento: se duplican (backoff exponencial).
  /// 3 esperas = 3 reintentos como máximo (RNF-RES-02, PS-10).
  static const List<Duration> defaultRetryDelays = <Duration>[
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 6),
  ];

  final PokemonRemoteDataSource _remote;
  final PokemonLocalDataSource _local;
  final int pageSize;

  /// Una espera por reintento. Lista vacía = sin reintentos.
  final List<Duration> retryDelays;

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
        final page = await _fetchWithRetries(cursor);

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

  /// Pide una página y, si falla por algo pasajero, la repite esperando
  /// cada vez más (RNF-RES-02). Lo que no se arregla esperando se lanza
  /// de inmediato.
  Future<CatalogPageDto> _fetchWithRetries(int cursor) async {
    var attempt = 0;

    while (true) {
      try {
        return await _remote.fetchCatalogPage(
          afterId: cursor,
          pageSize: pageSize,
        );
      } on PokeApiException catch (error) {
        // Se rinde si el error no es pasajero o si ya no quedan reintentos.
        final canRetry = _isTransient(error) && attempt < retryDelays.length;
        if (!canRetry) {
          rethrow;
        }

        final delay = retryDelays[attempt];
        attempt++;
        debugPrint(
          'Sync: falló la página tras id $cursor ($error). '
          'Reintento $attempt/${retryDelays.length} en ${delay.inSeconds} s',
        );
        await Future<void>.delayed(delay);
      }
    }
  }

  /// ¿Puede arreglarse solo con esperar y volver a intentar?
  /// RateLimit no: insistir solo gastaría más cuota de la hora.
  bool _isTransient(PokeApiException error) {
    return switch (error) {
      NoConnectionException() ||
      RequestTimeoutException() ||
      ServerErrorException() => true,
      RateLimitException() ||
      GraphQlResponseException() ||
      UnexpectedNetworkException() => false,
    };
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
