# ADR-0008: DAO del catálogo con streams reactivos y escritura transaccional por página

- **Estado:** Aceptado
- **Fecha:** 2026-10-26
- **Decidido por:** Almy y María

## Contexto

La interfaz debe observar la base local y no las respuestas de GraphQL (OF-16, OF-17, P-01). Cuando la sincronización guarda datos, la pantalla tiene que actualizarse sin que nadie la recargue. Además, la sincronización puede interrumpirse a mitad de una página, y no debe dejar datos parciales visibles (PS-07, PA-09, RNF-RES-04).

Si la sincronización reescribe filas con `insertOrReplace`, SQLite borra la fila antes de insertarla. Con `ON DELETE CASCADE` activo (ADR-0006), eso borraría en silencio los tipos y habilidades de cada Pokémon.

## Decisión

Centralizar el acceso al catálogo en un único DAO, `CatalogoDao`, con dos tipos de método:

**Lecturas reactivas.** Devuelven `Stream`, y Drift vuelve a emitir cuando cambia la tabla:
- `watchPokemons()`: lista ordenada por `id`.
- `watchCount()`: número de Pokémon guardados, para el umbral offline de la trivia (RF-TRV-05).
- `watchTypesOf(pokemonId)`: tipos ordenados por `slot`.
- `watchSyncState(resourceKey)`: estado de sincronización, para el indicador global (IND-04).

**Escritura por página.** `savePage(types, pokemons, pokemonTypes, syncState)` guarda una página completa en una sola transacción:
1. Upsert de tipos y Pokémon con `insertAllOnConflictUpdate`.
2. Reemplazo de las filas de `pokemon_types` de los Pokémon de la página.
3. Upsert del cursor en `sync_metadata`.

Reglas:
- Nunca `insertOrReplace` en el catálogo (ver Contexto).
- El cursor se guarda en la misma transacción que la página, para que la reanudación empiece donde debe (PS-07).
- La capa `data` del repositorio es la única que llama a `savePage`. La presentación no accede al DAO (OF-17).

## Alternativas consideradas

1. **Un método por Pokémon.** Más simple de escribir, pero una escritura por fila y una transacción por cada Pokémon. Con 250 por página, son muchas más escrituras y el progreso de la página no es atómico.
2. **`insertOrReplace` con `ON CONFLICT REPLACE`.** Escribe menos código, pero borra las filas antes de reinsertarlas y dispara las cascadas. Se descartó por el riesgo de perder tipos y habilidades sin aviso.
3. **Consultas puntuales (`Future`) en lugar de streams.** Obliga a recargar la pantalla después de cada escritura, lo que contradice OF-03 y la reactividad exigida en OF-16.
4. **Exponer las tablas directamente a la capa de datos.** Sin DAO, cada repositorio escribiría su propio SQL. Se descartó porque dispersa la lógica de transacciones.

## Consecuencias

**A favor**
- La UI se actualiza sola: basta con suscribirse al stream (OF-16).
- Una página es atómica: o se guarda completa, o no se guarda (PA-09).
- Repetir la misma página no duplica registros (PA-13).

**En contra**
- `watchPokemons()` devuelve la tabla completa. Para la lista de la UI habrá que agregar un método con límite y desplazamiento (`watchPage(limit, offset)`) en T-017, para cumplir RNF-REN-01.
- La firma de `savePage` depende de la interfaz del repositorio. Si ella necesita otra forma, el DAO se ajusta.

**Requisitos relacionados:** OF-03, OF-13, OF-16, OF-17, PS-05, PS-06, PS-07, PS-09, RNF-REN-01, RNF-RES-04, RF-TRV-05, IND-04, PA-09, PA-13, ADR-0003, ADR-0005, ADR-0006.