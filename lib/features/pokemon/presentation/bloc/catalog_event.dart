import 'package:pokedex/features/pokemon/domain/entities/catalogo_query.dart';

/// Eventos que recibe el Bloc del catálogo.
sealed class CatalogEvent {
  const CatalogEvent();
}

/// La pantalla se abrió: observar la base local y pedir una actualización.
final class CatalogStarted extends CatalogEvent {
  const CatalogStarted();
}

/// Se pidió actualizar. Por defecto es manual («Reintentar» o arrastrar hacia
/// abajo) y siempre sincroniza. Si [onlyIfStale] es true, es la actualización
/// automática del inicio y se omite cuando los datos están vigentes (PS-03).
final class CatalogRefreshRequested extends CatalogEvent {
  const CatalogRefreshRequested({this.onlyIfStale = false});

  final bool onlyIfStale;
}

/// El usuario escribió en la barra de búsqueda. Se aplica tras una pausa.
final class CatalogSearchChanged extends CatalogEvent {
  const CatalogSearchChanged(this.texto);

  final String texto;
}

/// Cambiaron tipos, generaciones u orden. Se aplican al momento.
final class CatalogFilterChanged extends CatalogEvent {
  const CatalogFilterChanged({
    this.tipoIds = const <int>{},
    this.generacionIds = const <int>{},
    this.orden = CatalogoOrden.numero,
  });

  final Set<int> tipoIds;
  final Set<int> generacionIds;
  final CatalogoOrden orden;
}

/// Interno: vuelve a observar la base con el criterio actual.
/// Lo dispara el Bloc, no la pantalla.
final class CatalogCriteriaApplied extends CatalogEvent {
  const CatalogCriteriaApplied();
}
