import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_game_result.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_question.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_rules.dart';
import 'package:pokedex/features/trivia/domain/repositories/trivia_repository.dart';
import 'package:pokedex/features/trivia/domain/usecases/calculate_question_score.dart';
import 'package:pokedex/features/trivia/domain/usecases/normalize_answer.dart';
import 'package:pokedex/features/trivia/presentation/cubit/trivia_game_state.dart';

/// Lleva una partida de trivia de principio a fin.
class TriviaGameCubit extends Cubit<TriviaGameState> {
  TriviaGameCubit({
    required this._repository,
    this.tick = const Duration(milliseconds: 100),
    this.imageGrace = const Duration(seconds: 5),
  }) : super(const TriviaGameLoading());

  final TriviaRepository _repository;

  /// Cada cuánto avanza el reloj. Se puede cambiar en las pruebas.
  final Duration tick;

  /// Máximo que se espera a la imagen antes de arrancar el reloj igual.
  final Duration imageGrace;
  Timer? _graceTimer;

  List<TriviaQuestion> _questions = const [];
  final List<TriviaAnswerRecord> _answers = [];
  int _index = 0;
  int _score = 0;
  int _streak = 0;
  int _elapsedMs = 0;
  Timer? _timer;

  /// Arma la partida. Se llama una sola vez al abrir la pantalla.
  Future<void> start() async {
    emit(const TriviaGameLoading());
    _answers.clear();
    _index = 0;
    _score = 0;
    _streak = 0;

    _questions = await _repository.pickQuestions();
    if (isClosed) {
      return;
    }

    if (_questions.isEmpty) {
      final available = await _repository.watchAvailablePokemonCount().first;
      if (!isClosed) {
        emit(TriviaGameNotEnoughData(available: available));
      }
      return;
    }

    _showQuestion();
  }

  /// El usuario escribió un nombre y pulsó "Responder".
  void submitAnswer(String typed) {
    final current = state;
    if (current is! TriviaGameQuestion) {
      return;
    }

    final correct = isCorrectAnswer(
      typed: typed,
      pokemonName: current.question.name,
    );
    _finishQuestion(
      current,
      outcome: correct ? TriviaOutcome.correct : TriviaOutcome.wrong,
    );
  }

  /// Pide una pista: se revela una letra más y se pierden 20 puntos.
  void useHint() {
    final current = state;
    if (current is! TriviaGameQuestion ||
        current.hintsUsed >= TriviaRules.maxHintsPerQuestion) {
      return;
    }

    final hints = current.hintsUsed + 1;
    emit(
      current.copyWith(
        hintsUsed: hints,
        revealedLetters: revealedLetters(
          pokemonName: current.question.name,
          hintsUsed: hints,
        ),
      ),
    );
  }

  /// "No lo sé": cuenta como fallo.
  void skip() {
    final current = state;
    if (current is TriviaGameQuestion) {
      _finishQuestion(current, outcome: TriviaOutcome.skipped);
    }
  }

  /// Desde la revelación: pasa a la siguiente pregunta o cierra la partida.
  Future<void> next() async {
    final current = state;
    if (current is! TriviaGameRevealed) {
      return;
    }

    if (current.isLast) {
      await _finishGame();
    } else {
      _index++;
      _showQuestion();
    }
  }

  // ---------- Internos ----------

  void _showQuestion() {
    final question = _questions[_index];
    _elapsedMs = 0;

    emit(
      TriviaGameQuestion(
        question: question,
        index: _index,
        total: _questions.length,
        millisecondsLeft: TriviaRules.secondsPerQuestion * 1000,
        hintsUsed: 0,
        revealedLetters: '',
        score: _score,
        streak: _streak,
      ),
    );
    // El reloj espera a que se vea la silueta; si tarda demasiado, arranca igual.
    _graceTimer?.cancel();
    _graceTimer = Timer(imageGrace, imageReady);
  }

  /// La pantalla avisa que la silueta ya se ve. Es seguro llamarla varias veces.
  void imageReady() {
    _graceTimer?.cancel();
    if (state is! TriviaGameQuestion || (_timer?.isActive ?? false)) {
      return;
    }
    _startTimer();
  }

  /// Detiene el reloj sin perder el tiempo ya gastado. Se usa mientras se
  /// muestra el diálogo de salir.
  void pause() {
    _timer?.cancel();
    _graceTimer?.cancel();
  }

  /// Reanuda el reloj donde se quedó. Si no hay una pregunta en curso
  /// (por ejemplo, en la revelación) no hace nada.
  void resume() => imageReady();

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(tick, (_) {
      final current = state;
      if (current is! TriviaGameQuestion) {
        _timer?.cancel();
        return;
      }

      // El tiempo se cuenta sumando ticks: así es igual en la app y en las
      // pruebas, y se detiene solo si la app se pausa.
      _elapsedMs += tick.inMilliseconds;
      final left = TriviaRules.secondsPerQuestion * 1000 - _elapsedMs;

      if (left <= 0) {
        _finishQuestion(current, outcome: TriviaOutcome.timeUp);
      } else if ((left / 1000).ceil() !=
          (current.millisecondsLeft / 1000).ceil()) {
        // Solo se reconstruye la pantalla cuando cambia el número de segundos.
        emit(current.copyWith(millisecondsLeft: left));
      }
    });
  }

  void _finishQuestion(
    TriviaGameQuestion current, {
    required TriviaOutcome outcome,
  }) {
    _timer?.cancel();
    _graceTimer?.cancel();

    final correct = outcome == TriviaOutcome.correct;
    final used = outcome == TriviaOutcome.timeUp
        ? TriviaRules.secondsPerQuestion * 1000
        : _elapsedMs;

    final points = calculateQuestionScore(
      correct: correct,
      millisecondsUsed: used,
      hintsUsed: current.hintsUsed,
    );

    // La racha perdida se guarda ANTES de reiniciarla.
    final streakLost = correct ? 0 : _streak;

    _score += points.total;
    _streak = correct ? _streak + 1 : 0;
    _answers.add(
      TriviaAnswerRecord(
        pokemonId: current.question.pokemonId,
        correct: correct,
        millisecondsUsed: used,
        hintsUsed: current.hintsUsed,
        points: points.total,
      ),
    );

    emit(
      TriviaGameRevealed(
        question: current.question,
        index: current.index,
        total: current.total,
        outcome: outcome,
        points: points,
        score: _score,
        streak: _streak,
        history: [for (final answer in _answers) answer.correct],
        millisecondsUsed: used,
        streakLost: streakLost,
      ),
    );
  }

  Future<void> _finishGame() async {
    final result = TriviaGameResult(answers: List.of(_answers));

    // El mejor puntaje anterior se lee ANTES de guardar esta partida.
    final before = await _repository.watchStats().first;
    final unlocked = await _repository.saveGame(result);
    if (isClosed) {
      return;
    }

    emit(
      TriviaGameFinished(
        result: result,
        newAchievements: unlocked,
        isNewBest: result.score > before.bestScore,
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _graceTimer?.cancel();
    return super.close();
  }
}
