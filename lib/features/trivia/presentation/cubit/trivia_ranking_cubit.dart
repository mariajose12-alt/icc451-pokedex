import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_ranking_item.dart';
import 'package:pokedex/features/trivia/domain/repositories/trivia_repository.dart';

/// Las mejores partidas guardadas en el teléfono (RF-TRV-03).
class TriviaRankingCubit extends Cubit<List<TriviaRankingItem>> {
  TriviaRankingCubit({required TriviaRepository repository}) : super(const []) {
    _subscription = repository.watchRanking().listen(emit);
  }

  late final StreamSubscription<List<TriviaRankingItem>> _subscription;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
