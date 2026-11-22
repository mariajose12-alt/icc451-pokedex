import 'dart:async';

import 'package:pokedex/core/connectivity/connectivity_monitor.dart';
import 'package:pokedex/core/connectivity/service_availability.dart';
import 'package:pokedex/features/trivia/data/datasources/local/trivia_image_cache.dart';
import 'package:pokedex/features/trivia/data/datasources/local/trivia_local_datasource.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_achievement.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_game_result.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_question.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_ranking_item.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_rules.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_stats.dart';
import 'package:pokedex/features/trivia/domain/repositories/trivia_repository.dart';
import 'package:pokedex/features/trivia/domain/usecases/compute_trivia_stats.dart';
import 'package:pokedex/features/trivia/domain/usecases/evaluate_achievements.dart';

/// La trivia funciona 100 % con la base local: La trivia funciona con la base
/// local y las imágenes ya guardadas: jugar no necesita internet
class OfflineFirstTriviaRepository implements TriviaRepository {
  OfflineFirstTriviaRepository({
    required this._local,
    required this._connectivity,
    required this._images,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final TriviaLocalDataSource _local;
  final ConnectivityMonitor _connectivity;
  final TriviaImageCache _images;

  // El reloj se puede cambiar en las pruebas para tener fechas fijas.
  final DateTime Function() _now;

  /// Sin red no se puede descargar nada: solo se juega con imágenes guardadas.
  bool get _isOffline => _connectivity.current == ServiceAvailability.offline;

  @override
  Future<List<TriviaAchievementId>> saveGame(TriviaGameResult game) async {
    // Estadísticas como quedarían CON esta partida, para evaluar los logros.
    final history = await _local.loadGames();
    final stats = computeTriviaStats([...history, game]);
    final alreadyUnlocked = await _local.loadUnlocked();

    final unlocked = evaluateAchievements(
      stats: stats,
      game: game,
      alreadyUnlocked: alreadyUnlocked,
    );

    // Partida y logros nuevos se guardan juntos (una transacción).
    await _local.saveGame(game, playedAt: _now(), unlocked: unlocked);
    return unlocked;
  }

  @override
  Stream<TriviaStats> watchStats() =>
      _local.watchGames().map(computeTriviaStats);

  @override
  Stream<List<TriviaRankingItem>> watchRanking({int limit = 10}) =>
      _local.watchRanking(limit);

  @override
  Stream<List<TriviaAchievementProgress>> watchAchievements() {
    // Cada vez que cambia el historial se recalcula el avance. Los logros se
    // guardan en la misma transacción que la partida, así que nunca se ven
    // desfasados.
    return _local.watchGames().asyncMap((games) async {
      final stats = computeTriviaStats(games);
      final unlocked = await _local.loadUnlocked();
      return [
        for (final id in TriviaAchievementId.values)
          TriviaAchievementProgress(
            id: id,
            unlocked: unlocked.contains(id),
            progress: unlocked.contains(id)
                ? id.target
                : achievementProgress(id, stats),
          ),
      ];
    });
  }

  @override
  Stream<int> watchAvailablePokemonCount() {
    late final StreamController<int> controller;
    StreamSubscription<int>? dbSubscription;
    StreamSubscription<ServiceAvailability>? netSubscription;
    var generation = 0;

    Future<void> recompute() async {
      final mine = ++generation;
      final count = await _countPlayable();
      // Si llegó un cambio más nuevo mientras se contaba, este resultado
      // ya no sirve.
      if (mine == generation && !controller.isClosed) {
        controller.add(count);
      }
    }

    controller = StreamController<int>(
      onListen: () {
        // Se recalcula si cambia el catálogo o la conectividad.
        dbSubscription = _local.watchPokemonCount().listen((_) => recompute());
        netSubscription = _connectivity.watch().listen((_) => recompute());
      },
      onCancel: () async {
        await dbSubscription?.cancel();
        await netSubscription?.cancel();
      },
    );
    return controller.stream;
  }

  @override
  Future<List<TriviaQuestion>> pickQuestions() async {
    final all = await _local.allQuestionsShuffled();
    final playable = _isOffline ? await _cachedQuestions(all) : all;

    if (playable.length < TriviaRules.minPokemonToPlay) {
      return const [];
    }
    return playable.take(TriviaRules.questionsPerGame).toList();
  }

  /// Cuántos Pokémon se pueden usar ahora mismo.
  Future<int> _countPlayable() async {
    if (!_isOffline) {
      return _local.watchPokemonCount().first;
    }
    return (await _cachedQuestions(await _local.allQuestionsShuffled())).length;
  }

  /// Deja solo las preguntas cuya imagen está guardada, conservando el orden.
  /// Se comprueba de 40 en 40: rápido, sin abrir mil consultas a la vez.
  Future<List<TriviaQuestion>> _cachedQuestions(
    List<TriviaQuestion> all,
  ) async {
    final result = <TriviaQuestion>[];
    for (var i = 0; i < all.length; i += 40) {
      final chunk = all.skip(i).take(40);
      final checked = await Future.wait(chunk.map(_offlineVersion));
      result.addAll(checked.whereType<TriviaQuestion>());
    }
    return result;
  }

  /// La pregunta tal cual si su artwork está guardado; si solo está el sprite
  /// (lo que guarda el catálogo), una copia que usa el sprite; si no hay
  /// ninguno, null.
  Future<TriviaQuestion?> _offlineVersion(TriviaQuestion question) async {
    final artwork = question.artworkUrl;
    if (artwork != null && await _images.isCached(artwork)) {
      return question;
    }
    final sprite = question.spriteUrl;
    if (sprite != null && await _images.isCached(sprite)) {
      return TriviaQuestion(
        pokemonId: question.pokemonId,
        name: question.name,
        nationalDexNumber: question.nationalDexNumber,
        typeNames: question.typeNames,
        spriteUrl: sprite,
      );
    }
    return null;
  }

  @override
  Future<String?> pickSilhouetteUrl() async {
    final all = await _local.allQuestionsShuffled();

    if (!_isOffline) {
      // Con conexión, el primero al azar que tenga imagen.
      for (final question in all) {
        final url = question.imageUrl;
        if (url != null) {
          return url;
        }
      }
      return null;
    }

    // Sin conexión, el primero al azar cuya imagen esté guardada. Se revisa
    // de 40 en 40 y se corta en cuanto aparece uno.
    for (var i = 0; i < all.length; i += 40) {
      final chunk = all.skip(i).take(40);
      final checked = await Future.wait(chunk.map(_offlineVersion));
      for (final question in checked) {
        if (question != null) {
          return question.imageUrl;
        }
      }
    }
    return null;
  }
}
