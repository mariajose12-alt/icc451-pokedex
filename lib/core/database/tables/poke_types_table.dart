import 'package:drift/drift.dart';

@DataClassName('TypeEntry')
class PokeTypes extends Table {
  IntColumn get id => integer()();

  // Para que no se repitan los tipos en la tabla
  TextColumn get name => text().unique()();

  @override
  Set<Column> get primaryKey => {id};
}