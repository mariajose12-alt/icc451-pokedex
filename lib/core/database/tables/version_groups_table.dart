import 'package:drift/drift.dart';

// Grupos de versión de los juegos (red-blue, gold-silver...). Los movimientos
// que aprende un Pokémon cambian según el grupo, y el selector de la pestaña
// Movs. se llena con esta tabla (RF-DET-05). Son 32 filas.
@DataClassName('VersionGroupEntry')
class VersionGroups extends Table {
  IntColumn get id => integer()();

  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}
