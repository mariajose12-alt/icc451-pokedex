import 'package:drift/drift.dart';

// Cadenas evolutivas (RF-DET-04). Una fila por especie de cada cadena.
// Equivale a EVOLUTION(from, to, trigger) del Diagrama 6: cada fila dice de
// qué especie viene (fromSpeciesId) y con qué condición evoluciona, y así se
// arma el árbol con ramas (Eevee).
//
// Sin claves foráneas hacia pokemons: una cadena puede incluir especies que
// el catálogo todavía no ha descargado, y el insert no debe fallar por eso.
@DataClassName('EvolutionNodeEntry')
class EvolutionNodes extends Table {
  IntColumn get chainId => integer()();

  // En las especies base, el id de la especie es el del Pokémon.
  IntColumn get speciesId => integer()();

  // Nombre guardado aquí para dibujar la cadena aunque la especie no esté
  // en el catálogo.
  TextColumn get speciesName => text()();

  // Especie de la que viene. Null en la primera de la cadena.
  IntColumn get fromSpeciesId => integer().nullable()();

  // Condición principal de la evolución (null en la primera de la cadena).
  // trigger: 'level-up', 'trade', 'use-item'...
  TextColumn get trigger => text().nullable()();
  IntColumn get minLevel => integer().nullable()();
  IntColumn get minHappiness => integer().nullable()();

  // PokeAPI manda '' cuando no hay condición de hora; se guarda como null.
  TextColumn get timeOfDay => text().nullable()();

  TextColumn get itemName => text().nullable()();

  @override
  Set<Column> get primaryKey => {chainId, speciesId};
}
