/// Consultas GraphQL del catálogo.
abstract final class PokemonQueries {
  /// Una página del catálogo, con paginación por cursor de id.
  ///
  /// Cómo funciona el cursor:
  ///  - $lastId es el último id que ya tenemos. Pedimos los que vienen DESPUÉS.
  ///  - order_by id asc garantiza un orden estable entre páginas.
  ///  - Primera página: lastId = 0. Siguiente: el id del último de la anterior.
  ///
  /// Se pide solo lo necesario (OE-02):
  ///  - is_default = true deja fuera las formas alternativas (mega, regionales).
  ///  - sprites(path: ...) trae solo la URL que queremos, no el JSON enorme.
  ///  - pokemon_aggregate da el total remoto, para saber cuándo terminar.
  static const String catalogPage = r'''
query CatalogPage($lastId: Int!, $pageSize: Int!) {
  pokemon(
    where: {is_default: {_eq: true}, id: {_gt: $lastId}}
    order_by: {id: asc}
    limit: $pageSize
  ) {
    id
    name
    height
    weight
    pokemonsprites {
      artwork: sprites(path: "other.official-artwork.front_default")
      sprite: sprites(path: "front_default")
    }
    pokemontypes {
      slot
      type { id name }
    }
    pokemonstats {
      base_stat
      stat { id }
    }
    pokemonspecy { id generation_id }
  }
  pokemon_aggregate(where: {is_default: {_eq: true}}) {
    aggregate { count }
  }
}
''';

  /// Tabla de efectividades entre tipos. Se pide una vez y se guarda.
  ///  - damage_factor viene en porcentaje: 0, 50, 100 o 200.
  ///  - Son unas 324 filas (18 × 18): caben en una sola llamada.
  static const String typeEfficacies = r'''
query TypeEfficacies {
  typeefficacy {
    damage_type_id
    target_type_id
    damage_factor
  }
}
''';

  /// Todo el detalle de un Pokémon en UNA llamada (RF-DET-03 al 09).
  ///  - base: los mismos datos del catálogo. Permite guardar un Pokémon que no
  ///    estaba (PA-02) y restaurar lo que alguien cambió en la base (PA-16).
  ///  - Los idiomas se filtran aquí: 7 = español, 9 = inglés. Sin filtro,
  ///    PokeAPI manda el texto en todos los idiomas.
  ///  - moves: solo los métodos 1 level-up, 2 egg, 3 tutor y 4 machine, y solo
  ///    de la forma base. Los de las otras formas se piden al elegirlas.
  static const String pokemonDetail = r'''
query PokemonDetail($id: Int!) {
  base: pokemon(where: {id: {_eq: $id}, is_default: {_eq: true}}) {
    id
    name
    height
    weight
    pokemonsprites {
      artwork: sprites(path: "other.official-artwork.front_default")
      sprite: sprites(path: "front_default")
    }
    pokemontypes {
      slot
      type { id name }
    }
    pokemonstats {
      base_stat
      stat { id }
    }
    pokemonspecy { id generation_id }
    pokemonabilities {
      is_hidden
      ability {
        id
        name
        abilitynames(where: {language_id: {_in: [7, 9]}}) { language_id name }
        abilityeffecttexts(where: {language_id: {_eq: 9}}) { short_effect }
      }
    }
  }
  species: pokemonspecies(where: {id: {_eq: $id}}) {
    pokemonegggroups { egggroup { name } }
    evolutionchain {
      id
      pokemonspecies(order_by: {id: asc}) {
        id
        name
        evolves_from_species_id
        pokemonevolutions {
          min_level
          min_happiness
          time_of_day
          evolutiontrigger { name }
          item { name }
        }
      }
    }
  }
  forms: pokemon(
    where: {pokemonspecy: {id: {_eq: $id}}}
    order_by: {id: asc}
  ) {
    id
    name
    is_default
    pokemontypes {
      slot
      type { id }
    }
    pokemonsprites {
      sprite: sprites(path: "front_default")
      shiny: sprites(path: "front_shiny")
      artwork: sprites(path: "other.official-artwork.front_default")
      artwork_shiny: sprites(path: "other.official-artwork.front_shiny")
    }
  }
  moves: pokemonmove(
    where: {
      pokemon_id: {_eq: $id}
      movelearnmethod: {id: {_in: [1, 2, 3, 4]}}
    }
  ) {
    level
    move { id name }
    movelearnmethod { id }
    versiongroup { id name }
  }
}
''';
}
