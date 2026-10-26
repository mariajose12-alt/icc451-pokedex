# Persistencia y sincronización (PS-01 a PS-12)

El enunciado (§11) pide que el equipo **defina, justifique y documente** doce decisiones sobre persistencia y sincronización, y evalúa la coherencia entre cada decisión, su justificación y el comportamiento demostrado. Este documento las reúne.

> **Cómo leer el estado de cada decisión**
> - **[Decidido]**: el equipo la tomó y está registrada.
> - **[Propuesto]**: hay una propuesta razonada, pendiente de confirmación por el equipo. Los valores concretos pueden cambiar.
> - **[Por decidir]**: falta tomar la decisión; se listan las opciones.
>
> Cada decisión indica también su **implementación**. Se actualiza conforme avancen las tareas.

## Resumen

| PS | Tema | Decisión | Estado | Implementación |
|---|---|---|---|---|
| PS-01 | Modelo de datos local | Tablas relacionales con Drift, claves de PokeAPI | Decidido (ajustes de detalle abiertos) | En desarrollo (T-006, T-007) |
| PS-02 | Carga inicial | Catálogo en 5 páginas en segundo plano; detalle bajo demanda | Decidido | En desarrollo (T-011, T-014) |
| PS-03 | Política de actualización | Vigencia de 24 h (catálogo) y 7 días (detalle) | Propuesto | Planificado |
| PS-04 | Sincronización automática y manual | Inicio, reconexión, detalle, periódica y manual | Decidido (intervalo periódico propuesto) | Parcial (monitor en T-012) |
| PS-05 | Identificación de registros | Id de PokeAPI como clave estable | Decidido | En desarrollo |
| PS-06 | Prevención de duplicados | Upsert por clave y unicidad del número de Pokédex | Decidido | En desarrollo |
| PS-07 | Sincronizaciones incompletas | Transacción por página y reanudación por cursor | Decidido | Planificado (T-014) |
| PS-08 | Persistencia de imágenes | Caché en disco con respaldo offline | Por decidir (límite y limpieza) | Planificado (T-009) |
| PS-09 | Registro de última sincronización | `sync_metadata` por recurso, expuesto al indicador | Decidido | Parcial (contrato listo, fuente falsa) |
| PS-10 | Recuperación ante fallos | Backoff exponencial con tope; migraciones de esquema | Propuesto | Planificado (T-035) |
| PS-11 | Separación de datos de usuario | Tablas de usuario independientes del catálogo | Decidido (relación con el catálogo abierta) | En desarrollo (T-007) |
| PS-12 | Detección de alteraciones locales | Sobrescritura con el dato remoto en cada actualización | Propuesto | Planificado |

---

## PS-01 · Modelo de datos local

**Decisión [Decidido].** Base SQLite con Drift, con tablas relacionales, claves primarias estables, relaciones con claves foráneas e índices para las consultas más frecuentes.

**Entidades del avance**

| Tabla | Clave | Contenido |
|---|---|---|
| Pokémon | `id` (el de PokeAPI) | Nombre, número de Pokédex nacional (único), generación, altura, peso, URL de artwork y de sprite, ruta local de la imagen, fecha de actualización |
| Tipos | `id` | Nombre del tipo elemental (único) |
| Pokémon–tipo | (`pokemon_id`, `slot`) | Relación con el tipo; el `slot` 1 es el tipo principal |
| Favoritos | `pokemon_id` | Datos del usuario, sin borrado en cascada |
| Metadatos de sincronización | `resource_key` | Última sincronización, estado, último id procesado y total remoto |

Para la entrega final se agregan habilidades (con su relación con el Pokémon), movimientos, evoluciones y trivia.

**Índices:** nombre (búsqueda), número de Pokédex (orden y búsqueda por número), generación (filtro) y tipo (en la relación Pokémon–tipo).

**Relación con el Diagrama 6.** El modelo sigue el modelo conceptual del enunciado, que no impone un esquema físico, con estos ajustes justificados:

- Se agregan `generation_id`, necesario para el filtro por generación (RF-FIL-01), y las URLs `artwork_url` y `sprite_url`, porque la interfaz y las entidades del dominio trabajan con URLs.
- Se conserva `artwork_local_path` para la caché de imágenes (PS-08).
- Las claves foráneas están activadas (`PRAGMA foreign_keys = ON`) para que las cascadas declaradas tengan efecto.

**Justificación.** Un modelo estructurado permite buscar, filtrar y ordenar sin red, y mantiene los datos del usuario en el mismo modelo local (§6.5 del enunciado). Una caché de respuestas no lo lograría.

**Implementación.** Esquema en cierre entre T-006 y T-007. El esquema vigente está en `lib/core/database/tables/`.

## PS-02 · Carga inicial

**Decisión [Decidido].**

- La app **abre de inmediato** y nunca espera a la red.
- El **catálogo** se descarga **en segundo plano y de forma progresiva**, en 5 páginas de 250 Pokémon, con solo los campos que necesita el listado (id, nombre, altura, peso, tipos, generación e imágenes). Ver [ADR-0003](adr/0003-sincronizacion-cursor-y-upsert.md).
- El **detalle completo** de un Pokémon (habilidades, estadísticas y demás) se descarga **bajo demanda** al abrirlo y se guarda localmente (PA-02).

**Disponibilidad local.** El total remoto (`pokemon_aggregate`) viaja en la misma petición, así que la app sabe si el catálogo local es parcial y la interfaz puede indicarlo (PA-05).

**Justificación.** El enunciado no exige el catálogo completo desde la primera ejecución (§6.2). Descargarlo en 5 llamadas es barato para la cuota y deja disponible el listado completo sin red tras la primera sincronización.

## PS-03 · Política de actualización

**Propuesta [Propuesto].** Un dato se considera **desactualizado** cuando su última sincronización exitosa supera:

- **24 horas** para el catálogo.
- **7 días** para el detalle de un Pokémon.

Un dato desactualizado **se sigue mostrando** (nunca se oculta) y se refresca en segundo plano cuando el servicio esté disponible.

**Justificación.** El catálogo de PokeAPI cambia poco (por ejemplo, cuando se añade una generación). Esos plazos mantienen los datos razonablemente al día sin gastar la cuota de 100 solicitudes por hora.

**Pendiente:** confirmar o ajustar los plazos.

## PS-04 · Sincronización automática y manual

**Decisión [Decidido].** La sincronización se dispara:

| Disparador | Descripción |
|---|---|
| Inicio de la app | Al abrir, si el servicio está disponible |
| Reconexión | Cuando el monitor detecta que el servicio vuelve a responder (PA-07) |
| Apertura del detalle | Comprueba la vigencia del Pokémon abierto (OF-20) |
| Periódica | Mientras el servicio esté disponible |
| Manual | El usuario pide actualizar (botón «Actualizar» o «Reintentar») |

**Detalle del monitor de disponibilidad [Decidido].** Verificación activa de la API cada 5 minutos con el servicio en línea y a los 30 s, 1, 2 y 5 minutos (tope) con el servicio caído. Ver [ADR-0007](adr/0007-monitor-de-conectividad-verificacion-activa.md).

**Intervalo de la sincronización periódica [Propuesto]:** entre 15 y 30 minutos.

**Concurrencia.** Solo una sincronización a la vez por recurso (RNF-RES-03); un nuevo disparo mientras hay otra en curso se ignora.

## PS-05 · Identificación de registros

**Decisión [Decidido].** Se usan las claves de PokeAPI, que son estables entre sincronizaciones:

- Pokémon, tipos y habilidades: el `id` de PokeAPI.
- Relación Pokémon–tipo: (`pokemon_id`, `slot`).
- Metadatos de sincronización: `resource_key` (por ejemplo, el nombre del recurso).
- Favoritos: `pokemon_id`.

**Justificación.** Una clave que no cambia permite actualizar el mismo registro en cada sincronización, en lugar de crear uno nuevo.

## PS-06 · Prevención de duplicados

**Decisión [Decidido].**

1. **Upsert por clave** (`insertOnConflictUpdate`): se inserta si no existe y se actualiza si existe. **Nunca `insertOrReplace`**, porque reemplazar equivale a borrar y reinsertar, y borraría en cascada las filas relacionadas.
2. **Restricciones de unicidad:** `national_dex_number` en Pokémon y `name` en tipos.
3. **Cursor por id:** no se vuelve a pedir lo ya procesado.
4. **Una transacción por página** (ver PS-07).

**Verificación.** Existe una prueba que comprueba que se rechaza un número de Pokédex duplicado. Falta una prueba de upsert que sincronice el mismo Pokémon varias veces y compruebe que el número de registros no cambia (PA-13).

## PS-07 · Sincronizaciones incompletas

**Decisión [Decidido].** Cada página se guarda **en una sola transacción, junto con el nuevo cursor** (`last_synced_id` en los metadatos): o entra todo o no entra nada. Si la sincronización se interrumpe (cierre de la app, pérdida de red, error), los datos ya guardados siguen siendo válidos y **al reanudar se continúa desde el último cursor guardado**, sin repetir ni perder páginas (PA-09). El recurso queda marcado como incompleto hasta alcanzar el total remoto.

## PS-08 · Persistencia de imágenes

**Estado [Por decidir]** en lo que se refiere a límite y limpieza.

**Ya definido:**

- Se usa `cached_network_image` con `flutter_cache_manager`: las imágenes ya vistas se guardan en disco y se muestran sin conexión (OF-08).
- Si una imagen no está disponible sin conexión, se muestra un recurso de respaldo.
- El listado usa el sprite pequeño y el detalle usa el artwork oficial.

**Por decidir (T-009):**

- Cuántas imágenes se conservan y el espacio máximo de la caché.
- Política de limpieza (por antigüedad, por número de archivos o ambas).
- Si se descargan por adelantado las imágenes del catálogo o solo las que el usuario ve.

## PS-09 · Registro de última sincronización

**Decisión [Decidido].** La tabla de metadatos guarda, **por recurso**: la fecha de la última sincronización exitosa, el estado, el último id procesado y el total remoto.

**Cómo llega al indicador global (IND-04).** El indicador no lee la base directamente: recibe un `SyncInfoSource` con dos datos (si se está sincronizando y la hora de la última sincronización). Esto mantiene separadas las dos dimensiones del modelo de estados (disponibilidad y sincronización, §7.4).

**Implementación.** El contrato y el indicador están listos; hasta T-014 la fuente es una versión falsa, por lo que la hora aparece como «sin sincronizar».

## PS-10 · Recuperación ante fallos

**Propuesta [Propuesto].**

- **Reintentos:** backoff exponencial de 2, 4, 8, 16 y 32 segundos, con un máximo de 5 intentos y un pequeño margen aleatorio (*jitter*) para no sincronizar reintentos. Pasado el límite, el recurso queda en «esperando reintento» hasta el siguiente disparador (RNF-RES-02).
- **Errores persistidos:** el estado de cada recurso (`completo`, `incompleto` o `fallido`) se guarda en los metadatos, así que sobrevive al cierre de la app.
- **Un fallo nunca elimina datos locales válidos** (OF-04).
- **Migraciones del esquema:** `schemaVersion` con una estrategia de migración definida (`MigrationStrategy`), de modo que un cambio de tablas en una versión futura no pierda los datos de favoritos ni de trivia.

**Pendiente:** confirmar los valores del backoff y el límite de intentos.

## PS-11 · Separación de datos de usuario

**Decisión [Decidido].** Los favoritos (y, en la entrega final, los resultados de trivia) viven en **tablas propias, independientes de las del catálogo**:

- La sincronización solo escribe en las tablas del catálogo.
- Los favoritos no tienen borrado en cascada: si un Pokémon cambiara en el catálogo, el favorito no se pierde (OF-21).
- La restauración de datos alterados (PS-12) se aplica solo al catálogo.

**Abierto:** si el favorito se relaciona con el Pokémon mediante una clave foránea sin cascada o guarda solo el id.

## PS-12 · Detección de alteraciones locales

**Propuesta [Propuesto].** **Sobrescritura con el dato remoto en cada actualización** (OF-19): como cada sincronización hace upsert de todos los campos del catálogo con lo que devuelve PokeAPI, cualquier valor alterado localmente se restaura y, ante un conflicto, prevalece siempre el dato remoto.

**Frecuencia.** Al iniciar, al recuperar la conectividad, al abrir el detalle y de forma periódica mientras el servicio esté disponible (OF-20).

**Justificación.** Es el mecanismo más simple y el que mejor garantiza que el dato remoto prevalece. Su costo es que escribe aunque no haya diferencias; se acepta porque el catálogo es pequeño (1025 filas).

**Alternativa descartada por ahora:** comparar un hash por registro y escribir solo los distintos. Ahorra escrituras, pero añade complejidad que el tamaño del catálogo no justifica.

**Demostración.** Con un inspector de base de datos (PA-16) se modifica un campo del catálogo, se actualiza y se comprueba que vuelve al valor de PokeAPI.
