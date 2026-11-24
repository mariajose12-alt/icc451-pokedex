import 'package:flutter/foundation.dart';
import 'package:pokedex/core/network/network_exceptions.dart';

/// ¿Puede arreglarse solo con esperar y volver a intentar?
/// RateLimit no: insistir solo gastaría más cuota de la hora.
bool isTransientError(PokeApiException error) {
  return switch (error) {
    NoConnectionException() ||
    RequestTimeoutException() ||
    ServerErrorException() => true,
    RateLimitException() ||
    GraphQlResponseException() ||
    UnexpectedNetworkException() => false,
  };
}

/// Ejecuta [action] y, si falla por algo pasajero, la repite esperando cada
/// vez más (backoff, RNF-RES-02). Hay un reintento por cada elemento de
/// [delays]. Lo que no se arregla esperando se lanza de inmediato.
Future<T> retryTransient<T>(
  Future<T> Function() action, {
  required List<Duration> delays,
  required String what,
}) async {
  var attempt = 0;

  while (true) {
    try {
      return await action();
    } on PokeApiException catch (error) {
      final canRetry = isTransientError(error) && attempt < delays.length;
      if (!canRetry) {
        rethrow;
      }

      final delay = delays[attempt];
      attempt++;
      debugPrint(
        'Sync: falló $what ($error). '
        'Reintento $attempt/${delays.length} en ${delay.inSeconds} s',
      );
      await Future<void>.delayed(delay);
    }
  }
}
