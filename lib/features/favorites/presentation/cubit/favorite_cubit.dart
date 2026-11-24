import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/features/favorites/domain/repositories/favorites_repository.dart';

/// ¿Este Pokémon es favorito? El estado es SOLO lo que dice la base: el
/// botón no cambia por su cuenta, espera a que la base avise (OF-16, OF-17).
class FavoriteCubit extends Cubit<bool> {
  FavoriteCubit({
    required FavoritesRepository repository,
    required int pokemonId,
  }) : _repository = repository,
       _pokemonId = pokemonId,
       super(false) {
    _subscription = repository.watchIsFavorite(pokemonId).listen((value) {
      if (!isClosed) {
        emit(value);
      }
    });
  }

  final FavoritesRepository _repository;
  final int _pokemonId;
  late final StreamSubscription<bool> _subscription;

  /// Agrega o quita. El cambio de pantalla llega por el stream.
  Future<void> toggle() async {
    await _repository.toggle(_pokemonId);
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
