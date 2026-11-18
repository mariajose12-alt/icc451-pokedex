import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/domain/entities/damage_matchups.dart';
import 'package:pokedex/features/pokemon/domain/entities/type_chart.dart';
import 'package:pokedex/features/pokemon/domain/entities/type_efficacy.dart';
import 'package:pokedex/features/pokemon/domain/usecases/calculate_matchups.dart';

const int _fighting = 2;
const int _flying = 3;
const int _ground = 5;
const int _rock = 6;
const int _bug = 7;
const int _fire = 10;
const int _water = 11;
const int _grass = 12;
const int _electric = 13;
const int _ice = 15;

TypeEfficacy _e(int attacker, int defender, int factor) {
  return TypeEfficacy(
    damageTypeId: attacker,
    targetTypeId: defender,
    damageFactor: factor,
  );
}

// Solo lo necesario para Fuego/Volador y Tierra. Lo que no aparece es 100 %.
final TypeChart _chart = TypeChart([
  _e(_rock, _fire, 200),
  _e(_rock, _flying, 200),
  _e(_water, _fire, 200),
  _e(_electric, _flying, 200),
  _e(_ground, _fire, 200),
  _e(_ground, _flying, 0),
  _e(_grass, _fire, 50),
  _e(_grass, _flying, 50),
  _e(_bug, _fire, 50),
  _e(_bug, _flying, 50),
  _e(_ice, _fire, 50),
  _e(_ice, _flying, 200),
  _e(_fighting, _flying, 50),
  _e(_electric, _ground, 0),
  _e(_water, _ground, 200),
]);

void main() {
  test('Fuego/Volador: ×4, ×2, ×0.5, ×0.25 e inmunidad, bien ordenados', () {
    final result = calculateMatchups(
      defenderTypeIds: [_fire, _flying],
      chart: _chart,
    );

    // Roca: 200 × 200 = ×4. Agua y Eléctrico: ×2 (id 11 antes que 13).
    expect(result.weaknesses, const [
      TypeMatchup(typeId: _rock, multiplierPercent: 400),
      TypeMatchup(typeId: _water, multiplierPercent: 200),
      TypeMatchup(typeId: _electric, multiplierPercent: 200),
    ]);

    // Bicho y Planta: 50 × 50 = ×0.25 (primero). Lucha: ×0.5.
    expect(result.resistances, const [
      TypeMatchup(typeId: _bug, multiplierPercent: 25),
      TypeMatchup(typeId: _grass, multiplierPercent: 25),
      TypeMatchup(typeId: _fighting, multiplierPercent: 50),
    ]);

    // Tierra: débil al Fuego (200) pero inmune por Volador (0) → inmunidad.
    expect(result.immunities, const [
      TypeMatchup(typeId: _ground, multiplierPercent: 0),
    ]);
  });

  test('un efecto ×2 y otro ×0.5 se cancelan y no se listan (Hielo)', () {
    final result = calculateMatchups(
      defenderTypeIds: [_fire, _flying],
      chart: _chart,
    );

    final ids = [
      ...result.weaknesses,
      ...result.resistances,
      ...result.immunities,
    ].map((m) => m.typeId);

    // Hielo: 50 × 200 / 100 = 100 → neutral.
    expect(ids, isNot(contains(_ice)));
  });

  test('un solo tipo: Tierra tiene una inmunidad y una debilidad', () {
    final result = calculateMatchups(defenderTypeIds: [_ground], chart: _chart);

    expect(result.weaknesses, const [
      TypeMatchup(typeId: _water, multiplierPercent: 200),
    ]);
    expect(result.immunities, const [
      TypeMatchup(typeId: _electric, multiplierPercent: 0),
    ]);
    expect(result.resistances, isEmpty);
  });

  test('sin tipos del Pokémon no hay matchups', () {
    final result = calculateMatchups(defenderTypeIds: [], chart: _chart);

    expect(result, DamageMatchups.empty);
    expect(result.isEmpty, isTrue);
  });

  test('con la tabla vacía (aún sin descargar) no hay matchups', () {
    final result = calculateMatchups(
      defenderTypeIds: [_fire],
      chart: TypeChart(const []),
    );

    expect(result.isEmpty, isTrue);
  });

  test('un par ausente en la tabla cuenta como daño normal (100 %)', () {
    final chart = TypeChart([_e(_water, _fire, 200)]);

    // Contra Planta no hay ninguna entrada: Agua es neutral y no se lista.
    final result = calculateMatchups(defenderTypeIds: [_grass], chart: chart);

    expect(result.isEmpty, isTrue);
  });
}