import 'package:equatable/equatable.dart';
import 'package:pokedex/core/errors/failures.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';

/// Estados de la pantalla del catálogo.
sealed class CatalogState extends Equatable {
  const CatalogState();

  @override
  List<Object?> get props => [];
}

/// Aún no ha empezado.
final class CatalogInitial extends CatalogState {
  const CatalogInitial();
}

/// Sin datos locales y esperando la primera actualización.
final class CatalogLoading extends CatalogState {
  const CatalogLoading();
}

/// Sin datos locales y sin nada en curso (p. ej. primera ejecución sin conexión).
final class CatalogEmpty extends CatalogState {
  const CatalogEmpty();
}

/// Sin datos locales y la actualización falló.
final class CatalogFailure extends CatalogState {
  const CatalogFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// Hay datos locales. Si la actualización falló, los datos se conservan
/// y solo se avisa (OF-04).
final class CatalogSuccess extends CatalogState {
  const CatalogSuccess({
    required this.pokemon,
    this.isRefreshing = false,
    this.refreshFailure,
  });

  final List<Pokemon> pokemon;
  final bool isRefreshing;
  final Failure? refreshFailure;

  @override
  List<Object?> get props => [pokemon, isRefreshing, refreshFailure];
}
