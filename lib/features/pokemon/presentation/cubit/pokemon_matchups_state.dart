import 'package:equatable/equatable.dart';
import 'package:pokedex/features/pokemon/domain/entities/damage_matchups.dart';

/// Lo que necesita la sección de matchups para dibujarse.
class PokemonMatchupsState extends Equatable {
  const PokemonMatchupsState({required this.matchups, required this.typeNames});

  /// Antes de que llegue la tabla: sin matchups y sin nombres.
  static const PokemonMatchupsState empty = PokemonMatchupsState(
    matchups: DamageMatchups.empty,
    typeNames: <int, String>{},
  );

  final DamageMatchups matchups;

  /// id de tipo → nombre ("fire"), para las etiquetas.
  final Map<int, String> typeNames;

  @override
  List<Object?> get props => [matchups, typeNames];
}
