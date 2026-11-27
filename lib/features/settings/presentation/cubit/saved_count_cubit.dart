import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/features/settings/domain/repositories/saved_pokemon_repository.dart';

/// Cuántos Pokémon hay guardados. Se actualiza solo cuando la base cambia,
/// por ejemplo mientras la sincronización va descargando el catálogo.
class SavedCountCubit extends Cubit<int> {
  SavedCountCubit({required SavedPokemonRepository repository}) : super(0) {
    _subscription = repository.watchCount().listen(emit);
  }

  late final StreamSubscription<int> _subscription;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
