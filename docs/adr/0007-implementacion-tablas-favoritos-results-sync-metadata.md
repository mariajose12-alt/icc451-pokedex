# ADR-0007: Datos del usuario y estado de sincronización en tablas separadas del catálogo

- **Estado:** Aceptado
- **Fecha:** 2026-10-26
- **Decidido por:** Almy

## Contexto

El enunciado exige que favoritos, puntuaciones y logros sean datos locales que funcionen sin conexión (RF-FAV-03, RF-TRV-03, OF-07, OF-09) y que la sincronización del catálogo nunca los modifique (OF-21, PS-11). 
También pide registrar el estado de cada sincronización por recurso (PS-09), que el indicador global usa para mostrar la vigencia de los datos (IND-04).

El catálogo se actualiza desde PokeAPI, pero los favoritos y la trivia no tienen equivalente remoto. Si ambos compartieran tablas o claves con cascada, una sincronización podría borrar datos del usuario.

## Decisión

Crear cuatro tablas separadas del catálogo:

- **`favorites`**: clave primaria `pokemon_id`. Un Pokémon es favorito una sola vez por instalación.
- **`trivia_results`**: una fila por partida, con id autoincremental, puntaje, aciertos y fecha.
- **`trivia_answers`**: una fila por pregunta de cada partida. `trivia_result_id` tiene `ON DELETE CASCADE`, así que borrar una partida borra sus respuestas.
- **`sync_metadata`**: una fila por recurso (`resource_key` como clave primaria), con última sincronización exitosa, estado y cursor para reanudar (PS-07).

Reglas:

- `favorites` **no** tiene cascada hacia `pokemons`. Si un Pokémon favorito se intenta borrar, la base de datos lo impide, y eso es deliberado: la sincronización del catálogo solo hace upserts.
- Los favoritos son locales al dispositivo. La app no tiene cuentas (§4.2), así que no hace falta `user_id`. Si se agregaran usuarios, la clave pasaría a `(user_id, pokemon_id)`.
- Los logros no se guardan en una tabla. Se calculan a partir de `trivia_results` y `trivia_answers`, para que cambiar un umbral no deje datos inconsistentes (ver T-032).

## Alternativas consideradas

1. **Una sola tabla de "marcas" para favoritos y catálogo.** Menos tablas, pero la sincronización podría sobrescribir campos del usuario.
2. **Cascada desde `pokemons` hacia `favorites`.** Limpia datos automáticamente, pero borraría favoritos si PokeAPI eliminara un Pokémon. Se descartó porque el enunciado exige que los datos del usuario no se vean afectados por el catálogo.
3. **Guardar favoritos en `SharedPreferences`.** Simple para una lista pequeña, pero no permite consultas combinadas con el catálogo (por ejemplo, filtrar favoritos por tipo) ni relaciones.
4. **Guardar los logros desbloqueados en una tabla.** Permite mostrar la fecha de desbloqueo, pero dos fuentes de verdad pueden desincronizarse si cambian los umbrales.

## Consecuencias

**A favor**
- La sincronización del catálogo puede ejecutarse sin riesgo para favoritos y trivia (PA-06, PA-09).
- Cada partida es auditable: se puede ver qué Pokémon se preguntó y cuál se contestó bien.
- Los logros siempre reflejan los datos actuales.

**En contra**
- Las tablas de trivia crecen con cada partida. Si hiciera falta, habría que agregar una política de limpieza.
- `status` en `sync_metadata` es texto libre por ahora (`"ok"`, `"syncing"`, `"failed"`). Pendiente decidir si se convierte en un enum en el dominio.
- Sin una tabla de logros, no se puede saber cuándo se desbloqueó cada uno.

**Requisitos relacionados:** RF-FAV-01 a RF-FAV-03, RF-TRV-03, RF-TRV-04, OF-07, OF-09, OF-21, PS-06, PS-07, PS-09, PS-11, IND-04, PA-06, PA-11, D6.