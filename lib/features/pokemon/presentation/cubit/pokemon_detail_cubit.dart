import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_detail_repository.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_detail_state.dart';

/// Estado del detalle de UN Pokémon. Solo lee de la base local a través del
/// repositorio (OF-16, OF-17): nunca consume una respuesta remota.
///
/// Si recibe [detailRepository], además pide la actualización al abrirse
/// (OF-20). La respuesta no pasa por aquí: se guarda en la base y el stream
/// de lectura emite el dato nuevo.
class PokemonDetailCubit extends Cubit<PokemonDetailState> {
  PokemonDetailCubit({
    required this._repository,
    required this.pokemonId,
    PokemonDetailRepository? detailRepository,
  }) : _refreshing = detailRepository != null && pokemonId > 0,
       super(const PokemonDetailLoading()) {
    // Se empieza a observar apenas se crea el cubit.
    _subscription = _repository.watchPokemon(pokemonId).listen(_onPokemon);

    if (_refreshing && detailRepository != null) {
      unawaited(_refresh(detailRepository));
    }
  }

  final PokemonRepository _repository;

  /// Id del Pokémon que muestra esta pantalla.
  final int pokemonId;

  late final StreamSubscription<Pokemon?> _subscription;

  // true mientras se espera la respuesta de PokeAPI.
  bool _refreshing;

  // Cada vez que la base emite, se traduce a un estado:
  //  - un Pokémon: se muestra (y se vuelve a mostrar si cambia en la base).
  //  - null mientras se consulta a PokeAPI: se sigue en Loading (PA-02).
  //  - null sin consulta pendiente: ese id no está guardado.
  void _onPokemon(Pokemon? pokemon) {
    if (pokemon != null) {
      emit(PokemonDetailSuccess(pokemon));
      return;
    }
    if (_refreshing) {
      return;
    }
    emit(const PokemonDetailNotFound());
  }

  Future<void> _refresh(PokemonDetailRepository detailRepository) async {
    var succeeded = true;
    try {
      await detailRepository.refreshDetail(pokemonId);
    } catch (_) {
      // Sin conexión, API caída, id inexistente... Si el Pokémon ya estaba
      // guardado se sigue mostrando; aquí solo se anota que falló.
      succeeded = false;
    }
    _refreshing = false;

    // Si falló y no hay nada que mostrar, ya no se espera nada más. Si tuvo
    // éxito, el Pokémon llega por el stream de la base.
    if (!succeeded && !isClosed && state is PokemonDetailLoading) {
      emit(const PokemonDetailNotFound());
    }
  }

  @override
  Future<void> close() async {
    // Sin esto, el stream de la base seguiría abierto al salir del detalle.
    await _subscription.cancel();
    return super.close();
  }
}
