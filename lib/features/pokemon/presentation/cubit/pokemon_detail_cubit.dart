import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_detail_state.dart';

/// Estado del detalle de UN Pokémon. Solo lee de la base local a través del
/// repositorio (OF-16, OF-17): nunca consume una respuesta remota.
class PokemonDetailCubit extends Cubit<PokemonDetailState> {
  PokemonDetailCubit({required this._repository, required this.pokemonId})
    : super(const PokemonDetailLoading()) {
    // Se empieza a observar apenas se crea el cubit.
    _subscription = _repository.watchPokemon(pokemonId).listen(_onPokemon);
  }

  final PokemonRepository _repository;

  /// Id del Pokémon que muestra esta pantalla.
  final int pokemonId;

  late final StreamSubscription<Pokemon?> _subscription;

  // Cada vez que la base emite, se traduce a un estado:
  //  - null: ese id no está guardado.
  //  - un Pokémon: se muestra (y se vuelve a mostrar si cambia en la base).
  void _onPokemon(Pokemon? pokemon) {
    if (pokemon == null) {
      emit(const PokemonDetailNotFound());
    } else {
      emit(PokemonDetailSuccess(pokemon));
    }
  }

  @override
  Future<void> close() async {
    // Sin esto, el stream de la base seguiría abierto al salir del detalle.
    await _subscription.cancel();
    return super.close();
  }
}
