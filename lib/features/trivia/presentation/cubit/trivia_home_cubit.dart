import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_stats.dart';
import 'package:pokedex/features/trivia/domain/repositories/trivia_repository.dart';

class TriviaHomeState extends Equatable {
  const TriviaHomeState({
    this.stats = const TriviaStats(),
    this.savedPokemon = 0,
    this.silhouetteUrl,
  });

  final TriviaStats stats;
  final int savedPokemon;

  /// Silueta de la portada. Se elige una vez al abrir la pantalla.
  final String? silhouetteUrl;

  TriviaHomeState copyWith({
    TriviaStats? stats,
    int? savedPokemon,
    String? silhouetteUrl,
  }) {
    return TriviaHomeState(
      stats: stats ?? this.stats,
      savedPokemon: savedPokemon ?? this.savedPokemon,
      silhouetteUrl: silhouetteUrl ?? this.silhouetteUrl,
    );
  }

  @override
  List<Object?> get props => [stats, savedPokemon, silhouetteUrl];
}

/// Récords y cantidad de Pokémon guardados para la pantalla de inicio.
/// Solo lee streams de la base local.
class TriviaHomeCubit extends Cubit<TriviaHomeState> {
  TriviaHomeCubit({required TriviaRepository repository})
    : super(const TriviaHomeState()) {
    _statsSubscription = repository.watchStats().listen(
      (stats) => emit(state.copyWith(stats: stats)),
    );
    _countSubscription = repository.watchAvailablePokemonCount().listen(
      (count) => emit(state.copyWith(savedPokemon: count)),
    );
    unawaited(_loadSilhouette(repository));
  }

  Future<void> _loadSilhouette(TriviaRepository repository) async {
    final url = await repository.pickSilhouetteUrl();
    if (!isClosed) {
      emit(state.copyWith(silhouetteUrl: url));
    }
  }

  late final StreamSubscription<TriviaStats> _statsSubscription;
  late final StreamSubscription<int> _countSubscription;

  @override
  Future<void> close() async {
    await _statsSubscription.cancel();
    await _countSubscription.cancel();
    return super.close();
  }
}
