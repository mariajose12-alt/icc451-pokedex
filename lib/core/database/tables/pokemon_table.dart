import 'package:drift/drift.dart';

// Se usa el nombre 'PokemonEntry' como nombre de la clase de datos
// para no confundirla con la entidad del dominio Pokemon

@DataClassName('PokemonEntry')
class Pokemon extends Table {
  // La clave viene del api
  IntColumn get id => integer()();

  TextColumn get name => text()();

  // Prevención de duplicados
  IntColumn get nationalDexNumber => integer().unique()();

  RealColumn get height => real().nullable()();

  RealColumn get weight => real().nullable()();

  // Ruta local de la imagen descargada
  TextColumn get artworkLocalPath => text().nullable()();

  // Ultima fecha de actualización
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}