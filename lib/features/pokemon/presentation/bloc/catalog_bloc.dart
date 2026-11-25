import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/core/errors/failures.dart';
import 'package:pokedex/features/pokemon/domain/entities/catalogo_query.dart';
import 'package:pokedex/features/pokemon/data/preferences/catalog_query_store.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_repository.dart';

import 'catalog_event.dart';
import 'catalog_state.dart';

/// Bloc del catálogo. Observa la base local a través del repositorio y pide
/// actualizaciones sin bloquear la pantalla. Nunca habla con la red.
class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc({
    required this._repository,
    required this._queryStore,
    this.searchDebounce = defaultSearchDebounce,
  }) : _query = _queryStore.load(),
       super(const CatalogInitial()) {
    on<CatalogStarted>(_onStarted);
    // droppable() -> si ya hay un refresh en curso, ignora los nuevos.
    on<CatalogRefreshRequested>(_onRefreshRequested, transformer: droppable());
    // transformer: restartable() -> impide que se acumulen los tiempos de
    // espera al usuario escribir en la búsqueda
    on<CatalogSearchChanged>(_onSearchChanged, transformer: restartable());
    on<CatalogFilterChanged>(_onFilterChanged);
    // restartable() -> cada criterio nuevo cancela la observación anterior.
    on<CatalogCriteriaApplied>(_onCriteriaApplied, transformer: restartable());
  }

  /// Pausa antes de aplicar la búsqueda (RF-CAT-03: entre 300 y 500 ms).
  static const Duration defaultSearchDebounce = Duration(milliseconds: 350);
  final Duration searchDebounce;

  final PokemonRepository _repository;
  final CatalogQueryStore _queryStore;
  // Criterio actual. Empieza con lo que se guardó la última vez.
  CatalogoQuery _query;

  // Lo que el Bloc necesita recordar para decidir qué mostrar.
  List<Pokemon> _pokemon = const [];
  bool _isRefreshing = false;
  Failure? _failure;
  // Ya llegó al menos un resultado de la base con el criterio actual.
  bool _observed = false;
  // Último texto escrito, para descartar búsquedas viejas durante el debounce.
  String _textoPendiente = '';

  /// Decide el estado a partir de los datos de arriba.
  CatalogState get _currentState {
    // Con filtros activos y ya observados, "sin resultados" es un caso válido.
    if (_pokemon.isNotEmpty || (_observed && _query.hasActiveFilters)) {
      return CatalogSuccess(
        pokemon: _pokemon,
        isRefreshing: _isRefreshing,
        refreshFailure: _failure,
        query: _query,
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

    // Automática: se omite si los datos locales siguen vigentes (PS-03).
    add(const CatalogRefreshRequested(onlyIfStale: true));
    // Empieza a observar la base con el criterio actual (OF-16).
    add(const CatalogCriteriaApplied());
  }

  Future<void> _onRefreshRequested(
    CatalogRefreshRequested event,
    Emitter<CatalogState> emit,
  ) async {
    _isRefreshing = true;
    _failure = null;
    emit(_currentState);

    try {
      await _repository.refreshCatalog(onlyIfStale: event.onlyIfStale);
    } on Failure catch (failure) {
      _failure = failure;
    } catch (_) {
      _failure = const UnknownFailure();
    }

    _isRefreshing = false;
    emit(_currentState);
  }

  Future<void> _onSearchChanged(
    CatalogSearchChanged event,
    Emitter<CatalogState> emit,
  ) async {
    _textoPendiente = event.texto;
    await Future<void>.delayed(searchDebounce);

    // Si el usuario escribió algo más durante la pausa, esta búsqueda ya no vale.
    if (event.texto != _textoPendiente) {
      return;
    }

    _query = _query.copyWith(nombre: event.texto.trim());
    add(const CatalogCriteriaApplied());
  }

  void _onFilterChanged(
    CatalogFilterChanged event,
    Emitter<CatalogState> emit,
  ) {
    _query = _query.copyWith(
      tipoIds: event.tipoIds,
      generacionIds: event.generacionIds,
      orden: event.orden,
    );
    add(const CatalogCriteriaApplied());
  }

  Future<void> _onCriteriaApplied(
    CatalogCriteriaApplied event,
    Emitter<CatalogState> emit,
  ) async {
    // Se guarda antes de observar: si la app se cierra, el criterio sobrevive.
    await _queryStore.save(_query);

    await emit.forEach<List<Pokemon>>(
      _repository.watchCatalogoFiltrado(_query),
      onData: (pokemon) {
        _pokemon = pokemon;
        _observed = true;
        _failure = null;
        return _currentState;
      },
    );
  }
}
