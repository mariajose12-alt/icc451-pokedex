import 'package:drift/drift.dart';
import 'package:pokedex/core/database/connection.dart';
import 'tables/pokemon_table.dart';
part 'app_database.g.dart';

@DriftDatabase(tables: [Pokemon])
class AppDatabase extends _$AppDatabase {

  // Constructor principal
  AppDatabase(super.executor);

  // Constructor para la app real, abre el archivo del telefono
  AppDatabase.archivo() : super(openConnection());

  @override
  int get schemaVersion => 1;

}