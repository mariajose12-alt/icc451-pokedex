import 'package:pokedex/features/pokemon/domain/entities/pokemon_form.dart';

// Los ids de tipo de PokeAPI son fijos. Las formas solo guardan el id, y esta
// tabla da el identificador que entiende TypeBadge.
const Map<int, String> _typeNamesById = {
  1: 'normal',
  2: 'fighting',
  3: 'flying',
  4: 'poison',
  5: 'ground',
  6: 'rock',
  7: 'bug',
  8: 'ghost',
  9: 'steel',
  10: 'fire',
  11: 'water',
  12: 'grass',
  13: 'electric',
  14: 'psychic',
  15: 'ice',
  16: 'dragon',
  17: 'dark',
  18: 'fairy',
};

/// Nombres de los tipos de una forma, en orden. Un id desconocido se omite.
List<String> formTypeNames(PokemonForm form) {
  final names = <String>[];
  for (final id in form.typeIds) {
    final name = _typeNamesById[id];
    if (name != null) {
      names.add(name);
    }
  }
  return names;
}
