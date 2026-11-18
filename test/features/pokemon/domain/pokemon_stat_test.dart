import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_stat.dart';

void main() {
  test('el porcentaje es el valor entre 255, redondeado', () {
    expect(const PokemonStat(statId: 2, baseStat: 84).percent, 33);
    expect(const PokemonStat(statId: 1, baseStat: 78).percent, 31);
  });

  test('0 es 0 % y 255 es 100 %', () {
    expect(const PokemonStat(statId: 1, baseStat: 0).percent, 0);
    expect(const PokemonStat(statId: 1, baseStat: 255).percent, 100);
  });

  test('un valor mayor a 255 no pasa de 100 %', () {
    const stat = PokemonStat(statId: 1, baseStat: 300);
    expect(stat.fraction, 1.0);
    expect(stat.percent, 100);
  });
}
