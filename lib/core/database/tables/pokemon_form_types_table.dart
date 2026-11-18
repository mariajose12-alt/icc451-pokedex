import 'package:drift/drift.dart';

// Tipos de cada forma (1 o 2). Cambian entre formas: Rattata es normal y
// Rattata de Alola es siniestro/normal (RF-DET-08).
//
// Sin clave foránea: es el mismo caso de pokemon_forms.
@DataClassName('PokemonFormTypeEntry')
class PokemonFormTypes extends Table {
  IntColumn get formId => integer()();

  IntColumn get typeId => integer()();

  IntColumn get slot => integer()();

  @override
  Set<Column> get primaryKey => {formId, slot};
}
