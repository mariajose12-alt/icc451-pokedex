import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/core/errors/failures.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_repository.dart';

import 'catalog_event.dart';
import 'catalog_state.dart';

/// Bloc del catálogo. Observa la base local a través del repositorio y pide
/// actualizaciones sin bloquear la pantalla. Nunca habla con la red.
class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc({required this._repository}) : super(const CatalogInitial()) {
    on<CatalogStarted>(_onStarted);
    on<CatalogRefreshRequested>(_onRefreshRequested);
  }

  final PokemonRepository _repository;

  // Lo que el Bloc necesita recordar para decidir qué mostrar.
  List<Pokemon> _pokemon = const [];
  bool _isRefreshing = false;
  Failure? _failure;

  /// Decide el estado a partir de los tres datos de arriba.
  CatalogState get _currentState {
    if (_pokemon.isNotEmpty) {
      return CatalogSuccess(
        pokemon: _pokemon,
        isRefreshing: _isRefreshing,
        refreshFailure: _failure,
      );
    }
    if (_isRefreshing) {
      return const CatalogLoading();
    }
    final failure = _failure;
    if (failure != null) {
      return CatalogFailure(failure);
    }
    return const CatalogEmpty();
  }

  Future<void> _onStarted(
    CatalogStarted event,
    Emitter<CatalogState> emit,
  ) async {
    // Se marca como "actualizando" desde el inicio para no mostrar un
    // estado vacío por un instante antes de la carga.
    _isRefreshing = true;
    emit(_currentState);

    // Pide la actualización sin esperarla: la pantalla no se bloquea (OF-03).
    add(const CatalogRefreshRequested());

    // Observa la base local: cada cambio produce un estado nuevo (OF-16).
    await emit.forEach<List<Pokemon>>(
      _repository.watchCatalog(),
      onData: (pokemon) {
        _pokemon = pokemon;
        return _currentState;
      },
    );
  }

  Future<void> _onRefreshRequested(
    CatalogRefreshRequested event,
    Emitter<CatalogState> emit,
  ) async {
    _isRefreshing = true;
    _failure = null;
    emit(_currentState);

    try {
      await _repository.refreshCatalog();
    } on Failure catch (failure) {
      _failure = failure;
    } catch (_) {
      _failure = const UnknownFailure();
    }

    _isRefreshing = false;
    emit(_currentState);
  }
}
