import 'package:drift/drift.dart';

// Estado de la ultima sincronización por recurso PS-09
// El indicador global lo lee para mostrar la vigencia de los datos IND-04
@DataClassName('SyncMetadataEntry')
class SyncMetadata extends Table {
  //Identificador estable del recurso
  TextColumn get resourceKey => text()();

  // Null si no sincronizó con exito
  DateTimeColumn get lastSuccessfulAt => dateTime().nullable()();

  // Estado de la ultima operación: "ok", "syncing", o "failed"
  TextColumn get status => text()();

  // Posicion para reanudar una paginación interrumpida
  TextColumn get cursorOrOffset => text().nullable()();

  @override
  Set<Column> get primaryKey => {resourceKey};
}
