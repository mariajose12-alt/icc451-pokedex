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
