import 'package:drift/drift.dart';

@DataClassName('AbilityEntry')
class Abilities extends Table {
  IntColumn get id => integer()();

  TextColumn get name => text()();

  TextColumn get effectSummary => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}