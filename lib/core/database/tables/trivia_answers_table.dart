import 'package:drift/drift.dart';

import 'pokemon_table.dart';
import 'trivia_results_table.dart';

// una fila por cada pokemon preguntado en una partida
@DataClassName('TriviaAnswersEntry')
class TriviaAnswers extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Si se borra la partida, se borran las respuestas de la misma
  IntColumn get triviaResultId =>
      integer().references(TriviaResults, #id, onDelete: KeyAction.cascade)();

  IntColumn get pokemonId => integer().references(Pokemons, #id)();

  BoolColumn get correct => boolean()();
}
