import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:pokedex/features/favorites/presentation/cubit/favorites_list_state.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';

/// Lista de favoritos. El estado sale SOLO de la base: quitar un favorito
/// escribe en la base y la pantalla cambia cuando la base avisa.
/// (No confundir con FavoriteCubit, que es el de UN Pokémon.)
class FavoritesListCubit extends Cubit<FavoritesListState> {
  FavoritesListCubit({required FavoritesRepository repository})
    : _repository = repository,
      super(const FavoritesListLoading()) {
    _subscription = repository.watchFavorites().listen((favorites) {
      _recent = favorites;
      _publish();
    });
  }

  final FavoritesRepository _repository;
  late final StreamSubscription<List<Pokemon>> _subscription;

  // Tal como llega de la base: el más reciente primero.
  List<Pokemon> _recent = const <Pokemon>[];
  FavoritesSort _sort = FavoritesSort.recent;

  void selectSort(FavoritesSort sort) {
    if (sort == _sort) {
      return;
    }
    _sort = sort;
    _publish();
  }

  Future<void> remove(int pokemonId) async {
    await _repository.toggle(pokemonId);
  }

  /// Deshacer: vuelve a agregarlo, pero solo si sigue sin ser favorito.
  /// Así un segundo toque no lo quita otra vez (toggle alterna).
  Future<void> undoRemove(int pokemonId) async {
    final alreadyBack = _recent.any((pokemon) => pokemon.id == pokemonId);
    if (alreadyBack) {
      return;
    }
    await _repository.toggle(pokemonId);
  }

  void _publish() {
    if (isClosed) {
      return;
    }
    if (_recent.isEmpty) {
      emit(FavoritesListEmpty(sort: _sort));
      return;
    }
    // Se ordena una copia: la lista original conserva "recientes".
    final sorted = List<Pokemon>.of(_recent);
    switch (_sort) {
      case FavoritesSort.recent:
        break;
      case FavoritesSort.name:
        sorted.sort((a, b) => a.name.compareTo(b.name));
      case FavoritesSort.number:
        sorted.sort(
          (a, b) => a.nationalDexNumber.compareTo(b.nationalDexNumber),
        );
    }
    emit(FavoritesListLoaded(items: sorted, sort: _sort));
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
