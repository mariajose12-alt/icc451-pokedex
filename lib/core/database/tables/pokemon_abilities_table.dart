import 'package:drift/drift.dart';

import 'abilities_table.dart';
import 'pokemon_table.dart';

@DataClassName('PokemonAbilityEntry')
class PokemonAbilities extends Table {
  IntColumn get pokemonId =>
      integer().references(Pokemons, #id, onDelete: KeyAction.cascade)();

  IntColumn get abilityId =>
      integer().references(Abilities, #id, onDelete: KeyAction.cascade)();

  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {pokemonId, abilityId};
}
