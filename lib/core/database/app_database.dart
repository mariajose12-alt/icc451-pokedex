import 'package:drift/drift.dart';
import 'tables/pokemon_table.dart';
part 'app_database.g.dart';

@DriftDatabase(tables: [Pokemon])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

}