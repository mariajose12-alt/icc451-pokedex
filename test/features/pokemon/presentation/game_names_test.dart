import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/game_names.dart';

void main() {
  test('da el nombre del juego en español e inglés', () {
    expect(versionGroupName('red-blue', 'es'), 'Rojo · Azul');
    expect(versionGroupName('red-blue', 'en'), 'Red · Blue');
    expect(versionGroupName('scarlet-violet', 'es'), 'Escarlata · Púrpura');
  });

  test('un grupo desconocido se muestra formateado', () {
    expect(versionGroupName('juego-nuevo', 'es'), 'Juego Nuevo');
  });
}
