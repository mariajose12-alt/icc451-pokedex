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
| PS-01 | Modelo de datos local | Tablas relacionales con Drift, claves de PokeAPI | Decidido | Implementado (T-006 a T-008); índices planificados |
| PS-02 | Carga inicial | Catálogo en 5 páginas en segundo plano; detalle bajo demanda | Decidido | Implementado (T-011, T-014) |
| PS-03 | Política de actualización | Vigencia de 24 h (catálogo) y 7 días (detalle) | Propuesto | Planificado |
| PS-04 | Sincronización automática y manual | Inicio, reconexión, detalle, periódica y manual | Decidido (intervalo periódico propuesto) | Parcial (monitor y sincronizador implementados; el disparo hoy es al abrir el catálogo; reconexión, periódica y detalle pendientes) |
| PS-05 | Identificación de registros | Id de PokeAPI como clave estable | Decidido | Implementado |
| PS-06 | Prevención de duplicados | Upsert por clave y unicidad del número de Pokédex | Decidido | Implementado y probado con el sincronizador |
| PS-07 | Sincronizaciones incompletas | Transacción por página y reanudación por cursor | Decidido | Implementado (T-014) |
| PS-08 | Persistencia de imágenes | Caché en disco con respaldo offline | Propuesto (valores por confirmar) | En desarrollo (T-009) |
| PS-09 | Registro de última sincronización | `sync_metadata` por recurso, expuesto al indicador | Decidido | Implementado (T-014) |
| PS-10 | Recuperación ante fallos | Backoff exponencial con tope; migraciones de esquema | Propuesto | Planificado (T-035) |
| PS-11 | Separación de datos de usuario | Tablas de usuario independientes del catálogo | Decidido | Implementado (T-007) |
| PS-12 | Detección de alteraciones locales | Sobrescritura con el dato remoto en cada actualización | Propuesto | Planificado |

---

## PS-01 · Modelo de datos local

**Decisión [Decidido].** Base SQLite con Drift, con tablas relacionales, claves primarias estables, relaciones con claves foráneas e índices para las consultas más frecuentes.

**Entidades del avance**

| Tabla | Clave | Contenido |
|---|---|---|
| `pokemons` | `id` (el de PokeAPI) | Nombre, número de Pokédex nacional (único), generación, altura, peso, URL de artwork y de sprite, ruta local de la imagen, fecha de actualización |
| `poke_types` | `id` | Nombre del tipo elemental (único) |
| `pokemon_types` | (`pokemon_id`, `slot`) | Relación con el tipo; el `slot` 1 es el tipo principal |
| `abilities`, `pokemon_abilities` | `id`; (`pokemon_id`, `ability_id`) | Habilidades y su relación con el Pokémon (se llenan con el detalle) |
| `favorites` | `pokemon_id` | Datos del usuario, sin borrado en cascada |
| `trivia_results`, `trivia_answers` | `id` | Partidas de trivia y sus respuestas |
| `sync_metadata` | `resource_key` | Última sincronización exitosa, estado y cursor para reanudar |

Para la entrega final se agregan movimientos y evoluciones.

**Índices.** Hoy existen las claves primarias, la unicidad del número de Pokédex y del nombre del tipo, y las claves foráneas. Están **planificados** índices por nombre (búsqueda), generación (filtro) y tipo, que se agregan cuando se implementen la búsqueda y los filtros.

**Relación con el Diagrama 6.** El modelo sigue el modelo conceptual del enunciado, que no impone un esquema físico, con estos ajustes justificados:

- Se agregan `generation_id`, necesario para el filtro por generación (RF-FIL-01), y las URLs `artwork_url` y `sprite_url`, porque la interfaz y las entidades del dominio trabajan con URLs.
- Se conserva `artwork_local_path` para la caché de imágenes (PS-08).
- Las claves foráneas están activadas (`PRAGMA foreign_keys = ON`) para que las cascadas declaradas tengan efecto.

**Justificación.** Un modelo estructurado permite buscar, filtrar y ordenar sin red, y mantiene los datos del usuario en el mismo modelo local (§6.5 del enunciado). Una caché de respuestas no lo lograría.

**Implementación.** Terminada en T-006 y T-007. El esquema vigente está en `lib/core/database/tables/` y se justifica en el [ADR-0006](adr/0006-diseño-tablas-catalogo.md) y el [ADR-0007](adr/0007-implementacion-tablas-favoritos-results-sync-metadata.md).

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

**Detalle del monitor de disponibilidad [Decidido].** Verificación activa de la API cada 5 minutos con el servicio en línea y a los 30 s, 1, 2 y 5 minutos (tope) con el servicio caído. Ver [ADR-0011](adr/0011-monitor-de-conectividad-verificacion-activa.md).

**Intervalo de la sincronización periódica [Propuesto]:** entre 15 y 30 minutos.

**Concurrencia [Implementado].** Solo una sincronización a la vez por recurso (RNF-RES-03): un nuevo disparo mientras hay otra en curso recibe esa misma operación y no genera llamadas nuevas.

**Estado de los disparadores.** Hoy solo está conectado el inicio (el catálogo pide actualizar al abrirse) y la actualización manual del Bloc. Reconexión, apertura del detalle y periódica están pendientes.

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

**Verificación.** En `test/core/database/` hay pruebas que comprueban que se rechaza un número de Pokédex duplicado y que guardar el mismo Pokémon tres veces no duplica registros (PA-13). Las pruebas del sincronizador (`test/features/pokemon/data/`) lo comprueban de punta a punta: descarga completa, reanudación y cierre con página vacía.

## PS-07 · Sincronizaciones incompletas

**Decisión [Decidido].** Cada página se guarda **en una sola transacción, junto con el nuevo cursor** (`cursor_or_offset` en los metadatos): o entra todo o no entra nada. Si la sincronización se interrumpe (cierre de la app, pérdida de red, error), los datos ya guardados siguen siendo válidos y **al reanudar se continúa desde el último cursor guardado**, sin repetir ni perder páginas (PA-09). El recurso queda con estado `syncing` hasta llegar a una página incompleta o vacía (la última).

**Implementación (T-014).** `CatalogSyncCoordinator` repite el ciclo «pedir página → guardarla con su cursor». Al empezar, `resumeCursor()` devuelve 0 si nunca se sincronizó o si la última terminó bien (se actualiza todo con upsert), y el cursor guardado si quedó `syncing` o `failed`. Cualquier error deja el estado en `failed`, conserva el cursor y lo ya descargado, y vuelve a lanzar el error original. Ver [ADR-0012](adr/0012-sincronizador-en-la-capa-data.md).

**Verificación.** Hay pruebas para la descarga de 600 Pokémon en tres llamadas, el cierre con página vacía, el fallo a mitad (conserva 250 y queda `failed`) y la reanudación sin repetir la primera página. La descarga completa de 1025 Pokémon se comprobó en el emulador de Android; la reanudación se comprueba con las pruebas automáticas.

## PS-08 · Persistencia de imágenes

**Propuesta [Propuesto].** Los valores concretos están pendientes de confirmar por el equipo. Ver [ADR-0009](adr/0009-cache-persistence-imagenes-respaldo-offline.md).

- **Dónde:** un único gestor de caché propio, que guarda los archivos en la **carpeta de documentos** de la app y no en la carpeta temporal, que el sistema puede vaciar (PA-10).
- **Qué se guarda:** solo las imágenes que el usuario llega a ver. No se descargan por adelantado las 1025 imágenes en la primera ejecución (PS-02).
- **Límite de espacio:** como máximo 300 archivos.
- **Política de limpieza:** los archivos con más de 30 días sin usarse se descartan, además del límite anterior.
- **Respaldo offline:** si una imagen no está disponible, se muestra una imagen de respaldo (`assets/images/dados.png`) sin errores (OF-08).
- **Registro:** la ruta local de cada imagen descargada se guarda en `artwork_local_path`.
- **Verificación:** se comprobó en un dispositivo Android que el archivo persiste después de reiniciar la app.

**Pendiente:** confirmar los valores de 300 archivos y 30 días, y conectar los widgets con imagen de respaldo (T-017).

## PS-09 · Registro de última sincronización

**Decisión [Decidido].** La tabla de metadatos guarda, **por recurso**: la fecha de la última sincronización exitosa, el estado (`ok`, `syncing` o `failed`) y el cursor para reanudar. El total remoto no se guarda: llega en cada respuesta (`pokemon_aggregate`).

**Cómo llega al indicador global (IND-04).** El indicador no lee la base directamente: recibe un `SyncInfoSource` con dos datos (si se está sincronizando y la hora de la última sincronización). Esto mantiene separadas las dos dimensiones del modelo de estados (disponibilidad y sincronización, §7.4).

**Implementación.** La tabla y el stream `watchSyncState` del DAO existen (T-007, T-008). Desde T-014, `DriftSyncInfoSource` combina dos orígenes: la hora de la última sincronización sale de la base (sobrevive al reinicio) y «está sincronizando» sale de la memoria del sincronizador. No se lee de la columna `status` porque, si la app se cierra a mitad, quedaría `syncing` guardado y el indicador mostraría «Sincronizando» para siempre. Ver [ADR-0012](adr/0012-sincronizador-en-la-capa-data.md).

## PS-10 · Recuperación ante fallos

**Propuesta [Propuesto].**

- **Reintentos:** backoff exponencial de 2, 4, 8, 16 y 32 segundos, con un máximo de 5 intentos y un pequeño margen aleatorio (*jitter*) para no sincronizar reintentos. Pasado el límite, el recurso queda en «esperando reintento» hasta el siguiente disparador (RNF-RES-02).
- **Errores persistidos:** el estado de cada recurso (`ok`, `syncing` o `failed`) se guarda en los metadatos, así que sobrevive al cierre de la app.
- **Un fallo nunca elimina datos locales válidos** (OF-04).
- **Migraciones del esquema:** `schemaVersion` (hoy en la versión 1) con una estrategia de migración ya preparada (`MigrationStrategy`, que también activa las claves foráneas en cada apertura), de modo que un cambio de tablas en una versión futura no pierda los datos de favoritos ni de trivia.

**Pendiente:** confirmar los valores del backoff y el límite de intentos.

## PS-11 · Separación de datos de usuario

**Decisión [Decidido].** Los favoritos (y, en la entrega final, los resultados de trivia) viven en **tablas propias, independientes de las del catálogo**:

- La sincronización solo escribe en las tablas del catálogo.
- Los favoritos no tienen borrado en cascada: si un Pokémon cambiara en el catálogo, el favorito no se pierde (OF-21).
- La restauración de datos alterados (PS-12) se aplica solo al catálogo.

**Relación con el catálogo [Decidido].** `favorites.pokemon_id` tiene una clave foránea hacia `pokemons` **sin cascada**: la base impide marcar como favorito un Pokémon inexistente y no borra favoritos por cambios del catálogo (ver [ADR-0007](adr/0007-implementacion-tablas-favoritos-results-sync-metadata.md)).

## PS-12 · Detección de alteraciones locales

**Propuesta [Propuesto].** **Sobrescritura con el dato remoto en cada actualización** (OF-19): como cada sincronización hace upsert de todos los campos del catálogo con lo que devuelve PokeAPI, cualquier valor alterado localmente se restaura y, ante un conflicto, prevalece siempre el dato remoto.

**Frecuencia.** Al iniciar, al recuperar la conectividad, al abrir el detalle y de forma periódica mientras el servicio esté disponible (OF-20).

**Justificación.** Es el mecanismo más simple y el que mejor garantiza que el dato remoto prevalece. Su costo es que escribe aunque no haya diferencias; se acepta porque el catálogo es pequeño (1025 filas).

**Alternativa descartada por ahora:** comparar un hash por registro y escribir solo los distintos. Ahorra escrituras, pero añade complejidad que el tamaño del catálogo no justifica.

**Demostración.** Con un inspector de base de datos (PA-16) se modifica un campo del catálogo, se actualiza y se comprueba que vuelve al valor de PokeAPI.
