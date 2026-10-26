# Decisiones tomadas y funcionamiento de la app

Documento de apoyo para entender **qué se decidió, por qué y cómo funciona** la Pokédex Offline-First. Complementa el README y los ADR, y sirve de guía de estudio para la defensa técnica.

> Cada punto indica si es **[Implementado]**, **[En desarrollo]** o **[Diseño]** (decidido, aún sin código). Se actualiza conforme avancen las tareas.

## 1. La idea central en una página

La app tiene **una sola regla de oro**:

> **La pantalla nunca lee de la red. La pantalla solo observa la base de datos local. La red solo escribe en la base de datos local.**

Todo lo demás se deduce de ahí:

- Sin Internet, la app sigue funcionando porque la pantalla nunca dependió de la red.
- Con Internet, la app baja datos en segundo plano, los guarda, y la pantalla se actualiza sola porque la base avisa del cambio.
- Si la red falla a mitad, los datos que ya estaban guardados no se pierden.

Una caché HTTP no cumple esto: solo recuerda respuestas idénticas ya hechas. Aquí los datos están **estructurados** (tablas, relaciones, índices), así que buscar, filtrar y ordenar funciona sin red, y los favoritos y la trivia viven en el mismo modelo.

## 2. Tabla de decisiones

| # | Decisión | Motivo corto | ADR | Estado |
|---|---|---|---|---|
| D1 | Drift (SQLite) como fuente de verdad | Consultas tipadas, índices, streams reactivos | 0001 | [En desarrollo] |
| D2 | BLoC / Cubit para el estado | Flujo explícito evento → estado | 0002 | [Implementado] |
| D3 | `get_it`, inyección por constructor | Dependencias sustituibles | 0002 | [Implementado] |
| D4 | Cursor por id, páginas de 250 | Reanudable, estable, pocas llamadas. Verificado en la consola el 26-oct | 0003 | [En desarrollo] |
| D5 | Upsert, nunca `insertOrReplace` | No borrar filas relacionadas | 0001, 0003 | [Diseño] |
| D6 | Cliente `graphql` de Dart puro | La UI no debe conocer GraphQL | 0004 | [Implementado] |
| D7 | `FetchPolicy.noCache` | La verdad es la base local | 0004 | [Implementado] |
| D8 | Timeout de 20 s | Margen para red móvil | 0004 | [Implementado] |
| D9 | Excepciones tipadas en la red, `Failure` en el dominio | Traducir errores por capa | 0004 | [Implementado] / [En desarrollo] |
| D10 | Clean Architecture por funcionalidades | Capas, dependencias hacia el dominio | 0005 | [Implementado] |
| D11 | Favoritos sin borrado en cascada | La sincronización no debe tocarlos | 0001 | [Diseño] |
| D12 | Sin `google_fonts` | Descarga por red, rompe el offline | — | [Implementado] |
| D13 | Colores por tipo con contraste ≥ 4.5:1 | Accesibilidad (WCAG 2.1 AA) | — | [Implementado] |
| D14 | `StatefulShellRoute.indexedStack` | Cada pestaña conserva su estado, sin parpadeos | — | [Implementado] |
| D15 | Indicador de conectividad en el shell | Un solo widget, visible en todas las pantallas | 0006 | [En desarrollo] |
| D16 | Número de Pokédex = id de la especie | Coincide con el número nacional | — | [Diseño] |
| D17 | Monitor con verificación activa de la API | «Hay red» no es «la API funciona» (IND-02) | 0007 | [En desarrollo] |
| D18 | Indicador con forma de lente y luces de Pokédex | Parte del diseño; no depende solo del color | 0006 | [En desarrollo] |
| D19 | DTO y mapeador separados de la entidad | Un cambio en la API toca una sola capa | 0003 | [En desarrollo] |
| D20 | Ventana de estabilidad de 1200 ms en el indicador | Evita parpadeos ante cambios breves (IND-06) | 0006 | [En desarrollo] |

## 3. Cómo viaja un dato, paso a paso

Ejemplo: el catálogo, desde PokeAPI hasta la pantalla.

1. **Disparo.** Algo pide actualizar (inicio de la app, reconexión, manual).
2. **Consulta.** El coordinador de sincronización pide una página al `PokeApiClient`, con el último id guardado como cursor.
3. **Cliente.** `PokeApiClient` hace el POST a GraphQL con timeout de 20 s. Si falla, lanza una `PokeApiException` tipada; si sale bien, devuelve un mapa con los datos.
4. **DTO y mapeador.** La capa `data` convierte el JSON en objetos de red (DTO) y los valida.
5. **Transacción.** En una sola transacción se hace *upsert* de los Pokémon, se actualizan sus tipos y se guarda el nuevo cursor en `sync_metadata`.
6. **La base avisa.** Drift emite un nuevo valor en el `Stream` que observa el repositorio.
7. **Repositorio.** Convierte las filas de la base en entidades del dominio y las publica.
8. **Bloc.** Recibe la lista y emite un estado (`Success`, o `Empty` si no hay nada).
9. **Widget.** Se reconstruye con el nuevo estado.

Observa que **el paso 9 no depende del 2 ni del 3**: si la red falla, la pantalla sigue mostrando lo que ya estaba en la base.

## 4. Qué hace cada capa y qué tiene prohibido

| Capa | Hace | Tiene prohibido |
|---|---|---|
| `presentation` | Pantallas, widgets, Blocs y sus estados | Importar `data`, `core/database` o `core/network` |
| `domain` | Entidades (`Pokemon`), contratos (`PokemonRepository`), fallos (`Failure`) | Importar Flutter, `graphql` o `drift` |
| `data` | Implementa los contratos; DTO, filas, mapeadores; coordina la sincronización | Pasar DTO a la presentación |
| `core` | Piezas comunes: red, base de datos, DI, errores | Convertirse en depósito de lógica de una funcionalidad |

Cada capa tiene **su propio tipo de modelo**: DTO (lo que llega de la red), fila (lo que está en la base) y entidad (lo que usa la app). Parece repetición, pero evita que un cambio en la API rompa las pantallas.

## 5. Cómo se comporta en cada escenario

| Escenario | Qué pasa | Estado del indicador |
|---|---|---|
| Primera vez, con Internet | La app abre de inmediato en estado vacío y la base se llena de forma progresiva | Sincronizando → Online |
| Con Internet, datos ya guardados | Muestra lo local y actualiza en segundo plano | Online |
| Sin Internet, con datos | Todo funciona con lo guardado; favoritos y trivia incluidos | Offline |
| Sin Internet, primera vez | Estado vacío con explicación, sin errores ni pantalla en blanco | Offline |
| Hay red pero la API no responde | Datos locales, reintentos con backoff; **nunca** muestra Online | Servicio no disponible |
| Se recupera la conexión | Detecta que la API responde, sincroniza sin que el usuario haga nada | Sincronizando → Online |
| Se interrumpe a mitad de la sincronización | La transacción impide datos a medias; se reanuda desde el cursor | según el caso |

## 6. Conectividad: dos dimensiones separadas

Hay que evitar estados contradictorios como «offline» y «API accesible» a la vez, así que el modelo interno guarda **dos dimensiones independientes**:

- **Disponibilidad del servicio:** `Verificando`, `Online`, `Offline` (sin red) o `Servicio no disponible` (hay red pero la API falla).
- **Sincronización:** `Inactiva`, `Sincronizando`, `Esperando reintento`, `Completada` o `Fallida`.

El indicador compone ambas más el **origen** (local o remoto) y la **vigencia** (hora de la última sincronización).

Dos ideas que conviene saber explicar:

1. **«Hay red» no es «la API funciona».** `connectivity_plus` solo avisa de que hay Wi-Fi o datos. El estado Online se decide con una verificación activa de la API.
2. **La verificación consume cuota.** PokeAPI permite 100 solicitudes por hora por IP, así que el monitor no consulta cada pocos segundos. Hace una consulta mínima (`pokemon(limit: 1) { id }`) cada 5 minutos si el servicio está en línea y, si está caído, espacia los reintentos (30 s, 1, 2 y 5 minutos como tope). Son como máximo 12 llamadas por hora.

### Cómo decide el monitor

Cada comprobación sigue estos pasos (ADR-0007):

1. `connectivity_plus` dice si hay red. Si no hay, el estado es **Offline** y no se llama a la API.
2. Si hay red, se hace la consulta mínima. Si responde, **Online**.
3. Si falla por cualquier motivo (timeout, límite de solicitudes, error del servidor), **Servicio no disponible**. El valor por defecto ante cualquier duda nunca es Online.
4. Se programa la siguiente comprobación según el resultado. En Offline no hay temporizador: se espera el evento de cambio de red.

Solo se emite un estado nuevo cuando cambia, y nunca hay dos comprobaciones a la vez. «Verificando» solo existe como estado inicial, para que el indicador no parpadee.

### El indicador con forma de Pokédex

El indicador compone las dos dimensiones y las dibuja como una Pokédex: un **lente azul** con un icono y **tres luces** (roja, amarilla y verde) sobre el rojo de la carcasa.

| Estado | Icono del lente | Luz | Texto |
|---|---|---|---|
| Online | nube con check | verde | En línea |
| Offline | nube tachada | roja | Sin conexión |
| Servicio no disponible | advertencia | amarilla | Servicio no disponible |
| Sincronizando | flechas circulares, el lente late | verde | Sincronizando… |
| Verificando | reloj de arena | ninguna | Verificando… |

Tres ideas para explicar en la defensa:

- **El color no es la única señal** (IND-05): cada estado tiene icono, texto, posición de la luz y una etiqueta Semantics que se lee de corrido.
- **Contradicciones imposibles:** «Sincronizando» solo se muestra si el servicio está Online.
- **Sin parpadeos** (IND-06): un cambio de disponibilidad solo se muestra si se mantiene 1200 ms. Si la red cae y vuelve en menos tiempo, el usuario no ve nada. La primera respuesta real se muestra sin esperar, porque no hay estado anterior que pueda parpadear. El lente solo late al sincronizar y se queda quieto si el sistema pide reducir las animaciones.

## 7. La sincronización explicada

- **Solo remoto → local.** PokeAPI es la autoridad del catálogo. Si hay conflicto, gana el dato remoto. Los favoritos y la trivia no tienen equivalente remoto y nunca se sobrescriben.
- **Cursor por id.** Se pide `id > último guardado`, ordenado por id, 250 por página. Así no se repite ni se salta nada y se puede reanudar. El catálogo completo son 5 llamadas.
- **Una transacción por página.** Datos y cursor se guardan juntos: o entra todo o no entra nada.
- **Upsert.** Se inserta si no existe y se actualiza si existe, por la clave estable (el id de PokeAPI). Por eso sincronizar tres veces seguidas deja el mismo número de registros (PA-13).
- **Por qué nunca `insertOrReplace`.** Reemplazar una fila equivale a borrarla y reinsertarla. Si hay filas que dependen de ella con borrado en cascada, se perderían.
- **Reintentos [Diseño].** Backoff exponencial con máximo de intentos (valores por definir) y una sola sincronización por recurso a la vez.
- **Restauración de datos alterados [Diseño].** Si alguien modifica un dato del catálogo en la base local, la app lo detecta y lo restaura con la versión de PokeAPI (al iniciar, al reconectar, al abrir el detalle y de forma periódica). El mecanismo exacto (sobrescribir en cada actualización o comparar hashes) está **pendiente de decidir** (PS-12).

## 8. Persistencia: las tablas y por qué son así

> Las decisiones PS-01 a PS-12, con su justificación y su estado, están en [persistencia-y-sincronizacion.md](../../../Downloads/persistencia-y-sincronizacion.md).

| Tabla | Contenido | Decisión clave |
|---|---|---|
| `pokemons` | Catálogo | Clave = id de PokeAPI; solo guarda las URLs de imagen, no el bloque completo de sprites |
| `types` | Tipos elementales | Clave = id de PokeAPI |
| `pokemon_types` | Relación Pokémon–tipo con su `slot` | Clave = (`pokemon_id`, `slot`); `slot` 1 es el tipo principal |
| `favorites` | Favoritos del usuario | **Sin borrado en cascada**: independiente del catálogo |
| `sync_metadata` | Estado por recurso | Guarda última sincronización, estado, último id procesado y total remoto |

Índices: `name` (búsqueda), `national_dex_number` (orden y búsqueda por número) y `generation_id` (filtro), más `type_id` en la relación con tipos.

Detalles que ayudan a entender:

- La **altura** y el **peso** se guardan como los entrega PokeAPI (decímetros y hectogramos) y se convierten al mostrarlos.
- El **número de Pokédex nacional** es el id de la especie (`pokemonspecy.id`), que para el Pokémon base coincide con su propio id.
- Se piden solo los Pokémon base (`is_default: true`); las formas regionales se agregan en el detalle.

## 9. Errores: cómo se transforman por capas

```text
Red / GraphQL      →  PokeApiException (core/network)   «qué falló en la infraestructura»
Capa data          →  Failure (core/errors)             «qué entiende el dominio»
Bloc               →  Estado Failure con mensaje        «qué ve el usuario, con Reintentar»
```

| Excepción de red | Failure del dominio |
|---|---|
| `NoConnectionException` | `NoConnectionFailure` |
| `RequestTimeoutException` | `TimeoutFailure` |
| `RateLimitException` | `RateLimitFailure` |
| `ServerErrorException`, `GraphQlResponseException` | `ServiceFailure` |
| `UnexpectedNetworkException` | `UnknownFailure` |

La presentación nunca ve una excepción de red ni un DTO.

## 10. Inyección de dependencias y BLoC

- Todo se registra en `main()` (el único lugar que usa `getIt`).
- Los Blocs reciben sus dependencias **por constructor**. Si un Bloc llamara a `getIt` por dentro, no se podría sustituir en pruebas.
- Los repositorios se registran **con el contrato del dominio** (`PokemonRepository`), no con la implementación.
- Singleton: base de datos, cliente GraphQL, monitor, sincronizador, repositorios. Un Bloc nuevo por pantalla, salvo el de conectividad, que vive en la raíz.
- Cada pantalla modela cinco estados: `Initial`, `Loading`, `Success`, `Empty` y `Failure`.

## 11. Límites de PokeAPI que condicionan el diseño

- **Solo POST** y versión `v1beta2` (sin el prefijo `pokemon_v2_` que tenían las versiones anteriores).
- **100 solicitudes por hora por IP.** Por eso: pocas llamadas, página de 250, conteo en la misma petición y verificaciones de salud espaciadas. Probar en una red compartida puede agotar la cuota.
- **Reinicio diario a la 1:00 UTC** (9 pm en República Dominicana), con unos 2 minutos sin servicio.
- **Política de uso justo:** guardar los datos en caché local.
- **Verificado el 26-oct-2026:** el cursor `id: {_gt: ...}` funciona (con `lastId: 3` llegan los Pokémon 4 y 5, y el total es 1025) y la consulta de salud `pokemon(limit: 1) { id }` responde.
- **Sin verificar:** cómo señala PokeAPI el límite de solicitudes (se asume HTTP 429) y la última página del cursor (`lastId: 1020` debería devolver 5 Pokémon).

## 12. Glosario

- **Offline-First:** la app se diseña para funcionar sin red; la red es una mejora, no un requisito.
- **Online-Preferred:** si hay red, se prioriza traer datos actualizados sin bloquear al usuario.
- **Fuente de verdad:** el lugar donde la interfaz lee los datos; aquí, la base local.
- **Upsert:** insertar si no existe, actualizar si existe.
- **Cursor:** marca del último registro procesado para pedir el siguiente grupo.
- **Backoff exponencial:** esperar cada vez más entre reintentos (por ejemplo 2, 4, 8 segundos).
- **DTO:** objeto que representa los datos tal como llegan de la red.
- **Entidad:** objeto del dominio, independiente de cómo se guarda o se transmite.
- **Raíz de composición:** el único lugar (`main.dart`) donde se construyen y conectan las dependencias.
- **ADR:** registro corto de una decisión de arquitectura: contexto, decisión, alternativas y consecuencias.


## 13. Preguntas probables en la defensa

**¿Por qué la pantalla nunca lee de la red?**
Porque la base local es la única fuente de verdad. Así la app funciona igual sin Internet, y un fallo de red no puede dejar la pantalla vacía ni borrar datos.

**¿Por qué hay DTO, fila y entidad si parecen lo mismo?**
Cada uno protege una frontera. Si PokeAPI cambia un campo, solo se toca el DTO; si cambia la base, solo la fila. El dominio y las pantallas no se enteran.

**¿Por qué cursor por id y no `offset`?**
Con `offset`, si los datos cambian entre páginas, se pueden repetir o saltar registros. El id no cambia, así que el cursor es estable y permite reanudar. Se comprobó en la consola: con `lastId: 3` llegan los Pokémon 4 y 5.

**¿Qué evita los duplicados?**
El upsert por id de PokeAPI y la restricción de unicidad del número de Pokédex. Sincronizar tres veces deja el mismo número de registros (PA-13).

**¿Qué pasa si la sincronización se interrumpe?**
Cada página se guarda en una transacción junto con el cursor: o entra todo o nada. Al reanudar, se continúa desde el último cursor guardado.

**¿Por qué no basta con `connectivity_plus`?**
Porque detecta que hay Wi-Fi o datos, no que la API responda. Un Wi-Fi sin Internet o una API caída mostrarían un Online falso. Por eso hay una verificación activa (IND-02).

**¿Cuántas llamadas gasta la app?**
Cinco para descargar el catálogo completo y, como máximo, doce por hora para verificar el servicio, frente a un límite de cien por hora por IP.

**¿Cómo evita que el indicador parpadee?**
Con una ventana de estabilidad: un cambio solo se muestra si se mantiene 1200 ms. La caída breve de red que vuelve antes de ese tiempo no se ve.

**¿Cómo cumple el indicador con no depender solo del color?**
Cada estado combina icono, texto, posición de la luz y una etiqueta Semantics. Las luces son un refuerzo visual, no la única señal.

**¿Qué limitación tiene el monitor?**
Un Wi-Fi sin Internet se muestra como «Servicio no disponible» y no como «Sin conexión», porque no hay forma de distinguirlo de una API caída sin gastar más cuota. Y una caída del servicio puede tardar hasta 5 minutos en reflejarse si no hay otra actividad de red.
