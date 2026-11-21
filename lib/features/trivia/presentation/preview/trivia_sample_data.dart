import 'package:pokedex/features/trivia/presentation/models/trivia_view_data.dart';
import 'package:pokedex/features/trivia/presentation/widgets/trivia_parts.dart';

/// TEMPORAL: datos de ejemplo para ver las pantallas mientras no exista el
/// motor de la trivia. Se elimina cuando las pantallas lean datos reales.
abstract final class TriviaSampleData {
  static const String _art =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/';

  static const TriviaHomeData home = TriviaHomeData(
    bestScore: 1240,
    streak: 5,
    gamesPlayed: 12,
    savedPokemon: 1025,
    silhouetteUrl: '${_art}1.png',
  );

  static const TriviaQuestionData question = TriviaQuestionData(
    questionNumber: 3,
    totalQuestions: 10,
    score: 240,
    secondsLeft: 9,
    totalSeconds: 15,
    nameLength: 9,
    typedText: 'Bul',
    imageUrl: '${_art}1.png',
  );

  static const TriviaRevealData correct = TriviaRevealData(
    questionNumber: 3,
    totalQuestions: 10,
    score: 390,
    pointsEarned: 150,
    speedBonus: 50,
    secondsUsed: 6,
    streakLost: 0,
    pokemonNumber: 1,
    pokemonName: 'bulbasaur',
    typeNames: ['grass', 'poison'],
    imageUrl: '${_art}1.png',
    dots: [
      AnswerDotState.correct,
      AnswerDotState.correct,
      AnswerDotState.correct,
      AnswerDotState.current,
      AnswerDotState.pending,
      AnswerDotState.pending,
      AnswerDotState.pending,
      AnswerDotState.pending,
      AnswerDotState.pending,
      AnswerDotState.pending,
    ],
  );

  static const TriviaRevealData timeUp = TriviaRevealData(
    questionNumber: 4,
    totalQuestions: 10,
    score: 390,
    pointsEarned: 0,
    speedBonus: 0,
    secondsUsed: 15,
    streakLost: 3,
    pokemonNumber: 4,
    pokemonName: 'charmander',
    typeNames: ['fire'],
    imageUrl: '${_art}4.png',
    dots: [
      AnswerDotState.correct,
      AnswerDotState.correct,
      AnswerDotState.correct,
      AnswerDotState.wrong,
      AnswerDotState.current,
      AnswerDotState.pending,
      AnswerDotState.pending,
      AnswerDotState.pending,
      AnswerDotState.pending,
      AnswerDotState.pending,
    ],
  );

  static const TriviaResultData result = TriviaResultData(
    score: 1240,
    correctCount: 7,
    total: 10,
    newRecord: true,
    achievementName: 'Experto',
    achievementDescription: '1 000 puntos en una partida',
    dots: [
      AnswerDotState.correct,
      AnswerDotState.correct,
      AnswerDotState.correct,
      AnswerDotState.wrong,
      AnswerDotState.correct,
      AnswerDotState.correct,
      AnswerDotState.wrong,
      AnswerDotState.correct,
      AnswerDotState.wrong,
      AnswerDotState.correct,
    ],
  );

  static final List<TriviaRankingEntry> ranking = [
    TriviaRankingEntry(
      score: 1240,
      correctCount: 7,
      total: 10,
      date: DateTime(2026, 11, 21),
      isNew: true,
    ),
    TriviaRankingEntry(
      score: 1180,
      correctCount: 8,
      total: 10,
      date: DateTime(2026, 11, 19),
    ),
    TriviaRankingEntry(
      score: 960,
      correctCount: 6,
      total: 10,
      date: DateTime(2026, 11, 17),
    ),
    TriviaRankingEntry(
      score: 850,
      correctCount: 6,
      total: 10,
      date: DateTime(2026, 11, 15),
    ),
    TriviaRankingEntry(
      score: 720,
      correctCount: 5,
      total: 10,
      date: DateTime(2026, 11, 12),
    ),
    TriviaRankingEntry(
      score: 640,
      correctCount: 4,
      total: 10,
      date: DateTime(2026, 11, 9),
    ),
    TriviaRankingEntry(
      score: 510,
      correctCount: 4,
      total: 10,
      date: DateTime(2026, 11, 5),
    ),
  ];

  static const List<TriviaAchievementData> achievements = [
    TriviaAchievementData(
      name: 'Primera partida',
      description: 'Termina una partida',
      unlocked: true,
      progress: 1,
      target: 1,
    ),
    TriviaAchievementData(
      name: 'Racha de 5',
      description: '5 aciertos seguidos',
      unlocked: true,
      progress: 5,
      target: 5,
    ),
    TriviaAchievementData(
      name: 'Relámpago',
      description: 'Acierta en menos de 3 s',
      unlocked: true,
      progress: 1,
      target: 1,
    ),
    TriviaAchievementData(
      name: 'Experto',
      description: '1 000 puntos en una partida',
      unlocked: true,
      progress: 1000,
      target: 1000,
    ),
    TriviaAchievementData(
      name: 'Perfecto',
      description: '10 de 10 en una partida',
      unlocked: false,
      progress: 8,
      target: 10,
    ),
    TriviaAchievementData(
      name: 'Sin pistas',
      description: 'Gana sin usar pistas',
      unlocked: false,
      progress: 0,
      target: 1,
    ),
    TriviaAchievementData(
      name: 'Entrenador',
      description: '50 aciertos en total',
      unlocked: false,
      progress: 31,
      target: 50,
    ),
    TriviaAchievementData(
      name: 'Coleccionista',
      description: 'Juega 25 partidas',
      unlocked: false,
      progress: 12,
      target: 25,
    ),
  ];

  static const TriviaNoDataData noData = TriviaNoDataData(
    saved: 12,
    required: 20,
  );
}
