import 'package:equatable/equatable.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';

/// Cómo se ordena la lista de favoritos.
enum FavoritesSort { recent, name, number }

sealed class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

/// Todavía no llegó la primera lectura de la base.
final class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

/// No hay favoritos (PA-15): la pantalla explica y sugiere una acción.
final class FavoritesEmpty extends FavoritesState {
  const FavoritesEmpty({required this.sort});

  final FavoritesSort sort;

  @override
  List<Object?> get props => [sort];
}

final class FavoritesLoaded extends FavoritesState {
  const FavoritesLoaded({required this.items, required this.sort});

  /// Ya ordenados según [sort].
  final List<Pokemon> items;
  final FavoritesSort sort;

  @override
  List<Object?> get props => [items, sort];
}
