import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_achievement.dart';
import 'package:pokedex/features/trivia/domain/repositories/trivia_repository.dart';

/// Los 8 logros con su avance (RF-TRV-04).
class TriviaAchievementsCubit extends Cubit<List<TriviaAchievementProgress>> {
  TriviaAchievementsCubit({required TriviaRepository repository})
    : super(const []) {
    _subscription = repository.watchAchievements().listen(emit);
  }

  late final StreamSubscription<List<TriviaAchievementProgress>> _subscription;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
