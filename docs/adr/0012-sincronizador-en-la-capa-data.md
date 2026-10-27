# ADR-0012: Sincronizador del catálogo en la capa data

- **Estado:** Aceptado
- **Fecha:** 2026-10-27
- **Decidido por:** María

## Contexto

La decisión del cursor por id y las páginas de 250 está en el [ADR-0003](0003-sincronizacion-cursor-y-upsert.md). Falta decidir **dónde vive el código que la ejecuta** (T-014) y cómo se entera el indicador global de que se está sincronizando.

La regla de la arquitectura es que las dependencias apuntan hacia el dominio ([ADR-0005](0005-clean-architecture-por-features.md)): la presentación no conoce `data`, y el dominio no conoce Drift, GraphQL ni los DTO.

## Decisión

1. **`CatalogSyncCoordinator` vive en `features/pokemon/data/sync/`.** Repite el ciclo «pedir una página → guardarla con su cursor» hasta que llega una página incompleta o vacía. Depende solo de la fuente remota y de la fuente local, ambas de la capa data.
2. **La pantalla no conoce el sincronizador.** El `CatalogBloc` solo usa el contrato `PokemonRepository` (`watchCatalog` y `refreshCatalog`). `OfflineFirstPokemonRepository` recibe el sincronizador por constructor, lee solo de la base y traduce las `PokeApiException` a `Failure`.
3. **Una sola sincronización a la vez.** Mientras hay una en curso, `sync()` devuelve esa misma operación en lugar de iniciar otra, para no gastar la cuota de 100 solicitudes por hora.
4. **Reanudación.** `PokemonLocalDataSource.resumeCursor()` devuelve 0 si nunca se sincronizó o si la última terminó bien (se actualiza todo con upsert), y el cursor guardado si quedó a medias o falló.
5. **Cualquier error deja el recurso en `failed`** conservando el cursor y lo ya descargado, y se vuelve a lanzar el error original.
6. **El indicador recibe la información por constructor.** `DriftSyncInfoSource` vive en `core/sync/` y no importa la feature: recibe el DAO y un `Stream<bool>` con «está sincronizando». `main.dart`, la raíz de composición, los conecta.
7. **`isSyncing` sale de la memoria del sincronizador, no de la base.** La hora de la última sincronización sí sale de la base (`sync_metadata`).
8. **Los streams con valor inicial usan `currentThenChanges`** (`core/async/`). Se suscribe a los cambios en el mismo instante en que alguien escucha, y recién entonces entrega el valor actual.

## Alternativas consideradas

1. **Un caso de uso `SyncCatalog` en el dominio.** Es más estricto, pero el bucle depende del cursor, de los DTO y de la transacción, que son detalles de data. Habría que inventar interfaces solo para ocultarlos, y hoy el caso de uso solo llamaría a `refreshCatalog()`. Queda abierto crear `usecases/` cuando aparezca la primera regla de negocio real.
2. **Que el Bloc llame al sincronizador.** Mezcla presentación con infraestructura y obliga al Bloc a conocer el cursor y los DTO.
3. **Leer `isSyncing` desde la columna `status` de la base.** Si la app se cierra a mitad de una descarga, el valor `syncing` queda guardado y el indicador mostraría «Sincronizando» para siempre.
4. **Streams con `async*` y `yield` para el valor inicial.** Dejan un hueco entre entregar el valor actual y suscribirse a los cambios, y un cambio que llegue en ese hueco se pierde.

## Consecuencias

**A favor**
- La pantalla y el dominio no cambian si se modifica la forma de sincronizar.
- Se prueba sin red y sin pantalla, con una API falsa y una base en memoria: descarga completa, fallo a mitad, reanudación, concurrencia y aviso de inicio y fin.
- El indicador no puede quedar atascado en «Sincronizando».

**En contra**
- No hay reintentos automáticos: hoy la descarga solo se dispara cuando la pantalla del catálogo pide actualizar. Si el servicio vuelve con la app abierta, no se reanuda sola hasta una nueva solicitud. Los disparadores de reconexión y periódico, y el backoff, están pendientes (PS-04, PS-10).
- Si el total de Pokémon fuera múltiplo exacto de 250, se hace una llamada extra que llega vacía. Con 1025 no ocurre.
- La señal de límite de solicitudes de PokeAPI sigue sin verificarse (se asume HTTP 429).

**Pruebas:** `test/features/pokemon/data/catalog_sync_coordinator_test.dart` cubre siete casos: descarga de 600 en tres llamadas, cierre con página vacía, fallo a mitad, reanudación desde el cursor, dos solicitudes simultáneas, aviso de inicio y fin, y lectura del catálogo con sus tipos.

**Requisitos relacionados:** OF-03, OF-04, OF-12, OF-13, PS-04, PS-06, PS-07, PS-09, RNF-RES-03, PA-09, PA-13.
