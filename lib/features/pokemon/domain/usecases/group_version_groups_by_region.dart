import 'package:pokedex/features/pokemon/domain/entities/game_region.dart';
import 'package:pokedex/features/pokemon/domain/entities/move_version_group.dart';

/// A qué región pertenece cada grupo de versión de PokeAPI. Hisui
/// (Leyendas: Arceus) cuenta como Sinnoh. Un grupo que no esté aquí (Colosseum,
/// XD o uno nuevo) simplemente no aparece en el mapa.
const Map<String, GameRegion> _regionByVersionGroup = {
  'red-blue': GameRegion.kanto,
  'yellow': GameRegion.kanto,
  'firered-leafgreen': GameRegion.kanto,
  'lets-go-pikachu-lets-go-eevee': GameRegion.kanto,
  'gold-silver': GameRegion.johto,
  'crystal': GameRegion.johto,
  'heartgold-soulsilver': GameRegion.johto,
  'ruby-sapphire': GameRegion.hoenn,
  'emerald': GameRegion.hoenn,
  'omega-ruby-alpha-sapphire': GameRegion.hoenn,
  'diamond-pearl': GameRegion.sinnoh,
  'platinum': GameRegion.sinnoh,
  'brilliant-diamond-and-shining-pearl': GameRegion.sinnoh,
  'legends-arceus': GameRegion.sinnoh,
  'black-white': GameRegion.unova,
  'black-2-white-2': GameRegion.unova,
  'x-y': GameRegion.kalos,
  'legends-za': GameRegion.kalos,
  'sun-moon': GameRegion.alola,
  'ultra-sun-ultra-moon': GameRegion.alola,
  'sword-shield': GameRegion.galar,
  'the-isle-of-armor': GameRegion.galar,
  'the-crown-tundra': GameRegion.galar,
  'scarlet-violet': GameRegion.paldea,
  'the-teal-mask': GameRegion.paldea,
  'the-indigo-disk': GameRegion.paldea,
};

/// Agrupa los juegos por región. Solo incluye las regiones que tienen al
/// menos un juego; las regiones salen en el orden del enum y los juegos de
/// cada una, del más viejo al más nuevo.
Map<GameRegion, List<MoveVersionGroup>> groupVersionGroupsByRegion(
  List<MoveVersionGroup> groups,
) {
  final result = <GameRegion, List<MoveVersionGroup>>{};
  for (final region in GameRegion.values) {
    final games = [
      for (final group in groups)
        if (_regionByVersionGroup[group.name] == region) group,
    ]..sort((a, b) => a.id.compareTo(b.id));
    if (games.isNotEmpty) {
      result[region] = games;
    }
  }
  return result;
}
