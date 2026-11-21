/// Cómo aprende un Pokémon un movimiento. El id es el de PokeAPI y coincide
/// con la columna learnMethodId de la base (solo se guardan estos cuatro).
enum MoveLearnMethod {
  levelUp(1),
  egg(2),
  tutor(3),
  machine(4);

  const MoveLearnMethod(this.id);

  final int id;
}

/// Orden de la lista de movimientos (RF-DET-05).
enum MovesOrder { level, name }
