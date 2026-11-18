import 'package:equatable/equatable.dart';

/// Un stat base de un Pokémon. Entidad del dominio.
class PokemonStat extends Equatable {
  const PokemonStat({required this.statId, required this.baseStat});

  /// 1 hp, 2 attack, 3 defense, 4 special-attack, 5 special-defense, 6 speed.
  /// Es el orden en que se muestran las barras.
  final int statId;

  /// Valor base (hasta 255). Con él se dibuja la barra.
  final int baseStat;

  /// Máximo valor posible de un stat base (el de Blissey en HP, por ejemplo).
  /// Es el 100 % de la barra.
  static const int maxBaseStat = 255;

  /// Qué parte de la barra se llena, de 0.0 a 1.0.
  /// clamp: si algún día llegara un valor mayor a 255, la barra no se sale.
  double get fraction => (baseStat / maxBaseStat).clamp(0.0, 1.0);

  /// Porcentaje entero para mostrar (RF-DET-02): 84 → 33.
  int get percent => (fraction * 100).round();

  @override
  List<Object?> get props => [statId, baseStat];
}
