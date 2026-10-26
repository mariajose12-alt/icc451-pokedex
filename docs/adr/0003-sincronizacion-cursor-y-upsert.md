# ADR-0003: Sincronización con cursor por id, páginas de 250 y upsert

- **Estado:** Propuesto (pendiente de implementar y validar con Almy en T-011 y T-014)
- **Fecha:** 2026-10-22
- **Decidido por:** María y Almy

## Contexto

PokeAPI documenta un límite de 100 solicitudes por hora por IP. La consulta del catálogo (1025 Pokémon base, solo con los campos necesarios) puede devolverse completa en una sola llamada, pero el enunciado exige paginación documentada y justificada (RF-CAT-02), reanudación ante interrupciones (PS-07, PA-09), ausencia de duplicados (OF-13, PA-13) y que la interfaz no se bloquee (OF-03). Debe poder cargarse de forma progresiva (PA-01).

## Decisión

1. **Paginación por cursor de id:** cada consulta pide los Pokémon con `id > último id procesado`, ordenados por `id` ascendente, en **páginas de 250**. El catálogo completo son 5 llamadas.
2. **El conteo total viaja en la misma petición** (`pokemon_aggregate`): sirve para el progreso, para saber si el catálogo local es parcial y para no gastar una llamada extra.
3. **Una transacción por página:** se guardan los Pokémon, sus tipos y el nuevo `lastSyncedId` (en `sync_metadata`) en la misma transacción. Una interrupción nunca deja datos a medias.
4. **Upsert por clave estable** (`insertOnConflictUpdate`) y nunca `insertOrReplace`, para no borrar filas relacionadas.
5. **Reanudación:** si hay un `lastSyncedId` guardado y el estado no es completo, se continúa desde ahí.
6. **Disparadores:** inicio de la app, recuperación de conectividad, apertura del detalle, intervalo periódico y actualización manual.

Pendiente de definir (se registrará en un ADR propio): valores del backoff exponencial y su límite de intentos, intervalo periódico, control de concurrencia por recurso y mecanismo de detección de alteraciones locales (OF-19, PS-12).

## Alternativas consideradas

1. **Una sola llamada con los 1025 Pokémon.** Mínimo de cuota, pero sin progreso visible, sin reanudación y con una transacción grande que bloquea más tiempo.
2. **Paginación por `offset`.** Más simple, pero si el orden cambia entre páginas puede repetir o saltarse registros. El cursor por id es estable.
3. **Descarga bajo demanda por Pokémon.** Gasta muchas llamadas y deja el catálogo vacío sin red.

## Consecuencias

**A favor**
- 5 llamadas para el catálogo completo, muy por debajo del límite horario.
- Interfaz progresiva y sincronización reanudable.
- Repetir la sincronización no duplica registros.

**En contra**
- Hay que guardar y gestionar el cursor en `sync_metadata`.
- El cursor depende de que el filtro `id: {_gt: ...}` siga disponible en la API.
- Si PokeAPI agrega o cambia Pokémon con ids menores al cursor, solo los detecta una sincronización completa (se cubre con la actualización periódica y la restauración de OF-19).

**Requisitos relacionados:** RF-CAT-02, OF-03, OF-12, OF-13, PS-05, PS-06, PS-07, PS-09, RNF-RES-04, PA-01, PA-09, PA-13.
