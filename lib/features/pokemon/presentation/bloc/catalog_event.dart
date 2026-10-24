/// Eventos que recibe el Bloc del catálogo.
sealed class CatalogEvent {
  const CatalogEvent();
}

/// La pantalla se abrió: observar la base local y pedir una actualización.
final class CatalogStarted extends CatalogEvent {
  const CatalogStarted();
}

/// El usuario pidió actualizar («Reintentar» o arrastrar hacia abajo).
final class CatalogRefreshRequested extends CatalogEvent {
  const CatalogRefreshRequested();
}
