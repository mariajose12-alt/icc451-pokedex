import 'package:drift/drift.dart';

// Una fila por partida de trivia
@DataClassName('TriviaResultEntry')
class TriviaResults extends Table {
  // La base de datos asigna el id automáticamente
  IntColumn get id => integer().autoIncrement()();

  IntColumn get score => integer()();

  IntColumn get correctAnswers => integer()();

  DateTimeColumn get playedAt => dateTime()();
}
