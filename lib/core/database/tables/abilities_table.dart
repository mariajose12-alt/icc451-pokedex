import 'package:drift/drift.dart';

@DataClassName('AbilityEntry')
class Abilities extends Table {
  IntColumn get id => integer()();

  TextColumn get name => text()();

  TextColumn get effectSummary => text().nullable()();

  // Nombre de la habilidad en español e inglés. Son nulos hasta que se abre
  // un Pokémon que la tenga (el detalle se baja bajo demanda).
  TextColumn get nameEs => text().nullable()();

  TextColumn get nameEn => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
