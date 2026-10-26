import 'package:drift/drift.dart';

// Se usa el nombre 'PokemonEntry' como nombre de la clase de datos
// para no confundirla con la entidad del dominio Pokemon

@DataClassName('PokemonEntry')
class Pokemons extends Table {
  // La clave viene del api
  IntColumn get id => integer()();

  TextColumn get name => text()();

  // Prevención de duplicados
  IntColumn get nationalDexNumber => integer().unique()();

  // Generación a la que pertenece. Lo usa el filtro RF-FIL-01.
  IntColumn get generationId => integer()();

  // Unidades de PokeAPI, altura en decímetros, peso en hectogramos.
  IntColumn get height => integer().nullable()();
  IntColumn get weight => integer().nullable()();

  // URLs remotas: la UI y la entidad de dominio trabajan con estas.
  TextColumn get artworkUrl => text().nullable()();
  TextColumn get spriteUrl => text().nullable()();

  // Ruta de la imagen descargada en el teléfono
  TextColumn get artworkLocalPath => text().nullable()();

  // Ultima fecha de actualización
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}