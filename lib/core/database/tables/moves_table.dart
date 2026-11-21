import 'package:drift/drift.dart';

// Catálogo de movimientos. Se llena al abrir el detalle de un Pokémon,
// con los movimientos que ese Pokémon puede aprender (RF-DET-05).
@DataClassName('MoveEntry')
class Moves extends Table {
  // Id tal como lo da PokeAPI (PS-05).
  IntColumn get id => integer()();

  // Identificador de PokeAPI, por ejemplo 'swords-dance'. La interfaz lo
  // convierte en texto legible.
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}
