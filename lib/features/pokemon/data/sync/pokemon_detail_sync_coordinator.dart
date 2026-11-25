import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pokedex/core/network/retry_transient.dart';
import 'package:pokedex/features/pokemon/data/datasources/local/pokemon_detail_local_datasource.dart';
import 'package:pokedex/features/pokemon/data/datasources/remote/pokemon_remote_datasource.dart';

/// Descarga el detalle de un Pokémon al abrirlo (PA-02, OF-20).
///
/// Política de vigencia (PS-03): se consulta en CADA apertura del detalle,
/// salvo que ya se haya consultado con éxito hace menos de [minInterval]
/// (10 segundos). Así se cumple OF-20, se cuida la cuota de 100 llamadas por
/// hora y se evita pedir lo mismo si el usuario entra y sale rápido.
class PokemonDetailSyncCoordinator {
  PokemonDetailSyncCoordinator({
    required this._remote,
    required this._local,
    this.minInterval = defaultMinInterval,
    this.retryDelays = defaultRetryDelays,
  });

  /// Solo evita pedir lo mismo si el usuario entra y sale del detalle en
  /// segundos. Debe ser corto: la comprobación de OF-19 ocurre al abrirlo.
  static const Duration defaultMinInterval = Duration(seconds: 10);

  /// Mismas esperas que el catálogo: 2, 4 y 6 segundos (RNF-RES-02).
  static const List<Duration> defaultRetryDelays = <Duration>[
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 6),
  ];

  final PokemonRemoteDataSource _remote;
  final PokemonDetailLocalDataSource _local;
  final Duration minInterval;

  /// Una espera por reintento. Lista vacía = sin reintentos.
  final List<Duration> retryDelays;

  // Consultas en curso, por id (RNF-RES-03). Dos pantallas que pidan el mismo
  // Pokémon a la vez comparten la misma consulta.
  final Map<int, Future<void>> _inFlight = <int, Future<void>>{};

  /// Actualiza el detalle del Pokémon [pokemonId]. Lanza la
  /// [PokeApiException] original si falla; quien llama decide qué mostrar.
  Future<void> refresh(int pokemonId) {
    final running = _inFlight[pokemonId];
    if (running != null) {
      return running;
    }

    final run = _refresh(pokemonId).whenComplete(() {
      _inFlight.remove(pokemonId);
    });
    _inFlight[pokemonId] = run;
    return run;
  }

  Future<void> _refresh(int pokemonId) async {
    // Consultado hace poco: no se gasta ninguna llamada.
    if (await _local.isFresh(pokemonId, minInterval)) {
      debugPrint('Sync: detalle $pokemonId vigente, no se consulta');
      return;
    }

    try {
      final detail = await retryTransient(
        () => _remote.fetchPokemonDetail(pokemonId),
        delays: retryDelays,
        what: 'el detalle del Pokémon $pokemonId',
      );
      await _local.save(detail);
    } catch (_) {
      // Lo ya guardado se conserva; solo se anota que falló.
      await _markFailedQuietly(pokemonId);
      rethrow;
    }
  }

  Future<void> _markFailedQuietly(int pokemonId) async {
    try {
      await _local.markFailed(pokemonId);
    } catch (_) {
      // Si ni siquiera se puede escribir el estado, se prioriza mostrar el
      // error original.
    }
  }
}
