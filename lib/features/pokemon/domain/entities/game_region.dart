/// Regiones principales de los juegos, una por generación. Son ficticias: el
/// mapa las dibuja como islas, no sobre un mapa real.
enum GameRegion {
  kanto('I', ['Bulbasaur', 'Charmander', 'Squirtle']),
  johto('II', ['Chikorita', 'Cyndaquil', 'Totodile']),
  hoenn('III', ['Treecko', 'Torchic', 'Mudkip']),
  sinnoh('IV', ['Turtwig', 'Chimchar', 'Piplup']),
  unova('V', ['Snivy', 'Tepig', 'Oshawott']),
  kalos('VI', ['Chespin', 'Fennekin', 'Froakie']),
  alola('VII', ['Rowlet', 'Litten', 'Popplio']),
  galar('VIII', ['Grookey', 'Scorbunny', 'Sobble']),
  paldea('IX', ['Sprigatito', 'Fuecoco', 'Quaxly']);

  const GameRegion(this.generation, this.starters);

  /// Generación en números romanos.
  final String generation;

  /// Los tres Pokémon iniciales de la región.
  final List<String> starters;
}
