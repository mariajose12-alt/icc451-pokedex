/// Valores permitidos de la columna `status` de SYNC_METADATA.
/// Se definen en un solo lugar para no escribir el texto a mano
/// en el sincronizador, el DAO y las pruebas.
abstract final class SyncStatus {
  /// La última sincronización terminó completa.
  static const String ok = 'ok';

  /// Hay una sincronización en curso o quedó a medias (hay cursor para reanudar).
  static const String syncing = 'syncing';

  /// La última sincronización falló. Los datos locales siguen siendo válidos.
  static const String failed = 'failed';
}

/// Claves de los recursos que se sincronizan (columna `resource_key`).
abstract final class SyncResources {
  static const String catalog = 'catalog';
}
