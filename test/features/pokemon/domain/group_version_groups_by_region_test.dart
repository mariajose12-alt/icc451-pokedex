import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/domain/entities/game_region.dart';
import 'package:pokedex/features/pokemon/domain/entities/move_version_group.dart';
import 'package:pokedex/features/pokemon/domain/usecases/group_version_groups_by_region.dart';

const _redBlue = MoveVersionGroup(id: 1, name: 'red-blue');
const _yellow = MoveVersionGroup(id: 2, name: 'yellow');
const _goldSilver = MoveVersionGroup(id: 3, name: 'gold-silver');
const _arceus = MoveVersionGroup(id: 24, name: 'legends-arceus');
const _scarletViolet = MoveVersionGroup(id: 25, name: 'scarlet-violet');

void main() {
  test('agrupa por región, juegos de viejo a nuevo y regiones en orden', () {
    final result = groupVersionGroupsByRegion(const [
      _scarletViolet,
      _yellow,
      _goldSilver,
      _redBlue,
    ]);

    expect(result.keys.toList(), [
      GameRegion.kanto,
      GameRegion.johto,
      GameRegion.paldea,
    ]);
    expect(result[GameRegion.kanto], [_redBlue, _yellow]);
    expect(result[GameRegion.paldea], [_scarletViolet]);
  });

  test('Leyendas: Arceus cuenta como Sinnoh', () {
    final result = groupVersionGroupsByRegion(const [_arceus]);

    expect(result.keys.toList(), [GameRegion.sinnoh]);
  });

  test('Colosseum, XD y los grupos desconocidos no aparecen', () {
    final result = groupVersionGroupsByRegion(const [
      MoveVersionGroup(id: 10, name: 'colosseum'),
      MoveVersionGroup(id: 11, name: 'xd'),
      MoveVersionGroup(id: 99, name: 'juego-nuevo-de-2030'),
      _redBlue,
    ]);

    expect(result.keys.toList(), [GameRegion.kanto]);
  });

  test('sin grupos devuelve un mapa vacío', () {
    expect(groupVersionGroupsByRegion(const []), isEmpty);
  });
}
