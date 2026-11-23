import 'package:drift/drift.dart';

// Tabla de efectividades entre tipos: cuánto daño hace un tipo atacante a un
// tipo defensor. Son 18 × 18 = 324 filas, se descargan una vez y permiten
// calcular los matchups del detalle sin red (RF-DET-06).
//
// Aquí NO hay claves foráneas hacia poke_types a propósito: es un dato de
// referencia independiente, y si se descargara antes de que el catálogo haya
// guardado todos los tipos, una clave foránea haría fallar el insert.
@DataClassName('TypeEfficacyEntry')
class TypeEfficacies extends Table {
  IntColumn get damageTypeId => integer()(); // tipo que ataca
  IntColumn get targetTypeId => integer()(); // tipo que defiende

  // Porcentaje tal como lo da PokeAPI: 0, 50, 100 o 200 (no ×0.5 ni ×2).
  IntColumn get damageFactor => integer()();

  @override
  Set<Column> get primaryKey => {damageTypeId, targetTypeId};
}
