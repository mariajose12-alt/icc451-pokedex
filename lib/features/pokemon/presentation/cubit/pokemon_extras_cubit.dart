import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_extras.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_detail_repository.dart';

/// Habilidades, egg groups, evoluciones y formas de UN Pokémon. Solo lee de la
/// base local a través del repositorio (OF-16, OF-17).
class PokemonExtrasCubit extends Cubit<PokemonExtras> {
  PokemonExtrasCubit({
    required PokemonDetailRepository repository,
    required int pokemonId,
  }) : super(PokemonExtras.empty) {
    _subscription = repository.watchExtras(pokemonId).listen(emit);
  }

  late final StreamSubscription<PokemonExtras> _subscription;

  @override
  Future<void> close() async {
    // Sin esto, el stream de la base seguiría abierto al salir del detalle.
    await _subscription.cancel();
    return super.close();
  }
}
