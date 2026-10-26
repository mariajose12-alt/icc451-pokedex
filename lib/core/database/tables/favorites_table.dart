import 'package:drift/drift.dart';
import 'pokemon_table.dart';

// Datos del usuario -> la sincronización del catálogo no los modifica PS-11
@DataClassName('FavoriteEntry')
class Favorites extends Table {

  //Clave primaria, un pokemon solo puede ser favorito una vez PS-06
  IntColumn get pokemonId => integer().references(Pokemons, #id)();
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {pokemonId};
  
}