import 'package:drift/drift.dart';

// Un logro desbloqueado. Solo se guarda CUÁNDO se desbloqueó: el avance
// (por ejemplo 12/50) se calcula siempre desde el historial.
@DataClassName('TriviaAchievementEntry')
class TriviaAchievements extends Table {
  // Nombre del logro (TriviaAchievementId.name), por ejemplo 'firstGame'.
  TextColumn get id => text()();

  DateTimeColumn get unlockedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
