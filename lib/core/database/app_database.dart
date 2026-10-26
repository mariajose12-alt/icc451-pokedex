import 'package:drift/drift.dart';

import 'connection.dart';
import 'tables/abilities_table.dart';
import 'tables/poke_types_table.dart';
import 'tables/pokemon_abilities_table.dart';
import 'tables/pokemon_table.dart';
import 'tables/pokemon_types_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Pokemon,
    PokeTypes,
    Abilities,
    PokemonTypes,
    PokemonAbilities,
  ],
)
class AppDatabase extends _$AppDatabase {

  // Constructor principal
  AppDatabase(super.executor);

  // Constructor para la app real, abre el archivo del telefono
  AppDatabase.archivo() : super(openConnection());

  @override
  int get schemaVersion => 1;

}