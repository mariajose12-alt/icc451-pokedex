import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_stats.dart';
import 'package:pokedex/features/trivia/domain/repositories/trivia_repository.dart';

class TriviaHomeState extends Equatable {
  const TriviaHomeState({
    this.stats = const TriviaStats(),
    this.savedPokemon = 0,
  });

  final TriviaStats stats;
  final int savedPokemon;

  TriviaHomeState copyWith({TriviaStats? stats, int? savedPokemon}) {
    return TriviaHomeState(
      stats: stats ?? this.stats,
      savedPokemon: savedPokemon ?? this.savedPokemon,
    );
  }

  @override
  List<Object?> get props => [stats, savedPokemon];
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
