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
    pokemonspecy { id generation_id }
  }
  pokemon_aggregate(where: {is_default: {_eq: true}}) {
    aggregate { count }
  }
}
''';
}
