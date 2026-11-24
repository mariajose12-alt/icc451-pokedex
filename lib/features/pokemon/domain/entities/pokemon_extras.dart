import 'package:equatable/equatable.dart';
import 'package:pokedex/features/pokemon/domain/entities/evolution_stage.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_ability.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_form.dart';

/// Lo que se descarga al abrir el detalle de un Pokémon, sin los movimientos
/// (son muchos y se leen aparte).
class PokemonExtras extends Equatable {
  const PokemonExtras({
    this.downloaded = false,
    this.abilities = const <PokemonAbility>[],
    this.eggGroups = const <String>[],
    this.evolution = const <EvolutionStage>[],
    this.forms = const <PokemonForm>[],
  });

  /// Todavía no se ha descargado nada de este Pokémon.
  static const PokemonExtras empty = PokemonExtras();

  /// ¿Se descargó alguna vez con éxito? Distingue «aún no llegó» de «llegó y
  /// no tiene» (por ejemplo, un Pokémon sin evoluciones).
  final bool downloaded;

  /// Primero las normales y al final la oculta.
  final List<PokemonAbility> abilities;

  /// Identificadores de PokeAPI: 'monster', 'plant'...
  final List<String> eggGroups;

  /// Todas las especies de su cadena evolutiva (lista plana).
  final List<EvolutionStage> evolution;
  final List<PokemonForm> forms;

  @override
  List<Object?> get props => [
    downloaded,
    abilities,
    eggGroups,
    evolution,
    forms,
  ];
}
