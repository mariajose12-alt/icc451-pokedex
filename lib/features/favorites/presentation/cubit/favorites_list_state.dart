import 'package:equatable/equatable.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';

/// Cómo se ordena la lista de favoritos.
enum FavoritesSort { recent, name, number }

sealed class FavoritesListState extends Equatable {
  const FavoritesListState();

  @override
  List<Object?> get props => [];
}

/// Todavía no llegó la primera lectura de la base.
final class FavoritesListLoading extends FavoritesListState {
  const FavoritesListLoading();
}

/// No hay favoritos (PA-15): la pantalla explica y sugiere una acción.
final class FavoritesListEmpty extends FavoritesListState {
  const FavoritesListEmpty({required this.sort});

  final FavoritesSort sort;

  @override
  List<Object?> get props => [sort];
}

final class FavoritesListLoaded extends FavoritesListState {
  const FavoritesListLoaded({required this.items, required this.sort});

  /// Ya ordenados según [sort].
  final List<Pokemon> items;
  final FavoritesSort sort;

  @override
  List<Object?> get props => [items, sort];
}
