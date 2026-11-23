# Pokédex Offline-First

Aplicación móvil multiplataforma hecha con **Flutter** que consume la API GraphQL de **PokeAPI** y sigue funcionando con o sin Internet, gracias a una arquitectura **Offline-First con comportamiento Online-Preferred**: la interfaz siempre lee de una base de datos local y, cuando el servicio está disponible, la actualiza en segundo plano.

Proyecto final de *Desarrollo de Aplicaciones Móviles* · Escuela de Ingeniería en Computación y Telecomunicaciones · PUCMM.
Docente: Freddy Peña (fr.pena@ce.pucmm.edu.do).

**Equipo:** María José Cruz · Almy Otoniela

> **Estado de este documento: primera entrega (avance), 10-nov-2026.**
> Cada sección indica si lo descrito está **Implementado**, **En desarrollo** o **Planificado**. Este README se actualiza a medida que avanza el proyecto.

## Estado del proyecto

| Área | Estado |
|---|---|
| Proyecto Flutter, linter estricto y repositorio (T-001) | Implementado |
| Estructura Clean Architecture por funcionalidades (T-002) | Implementado |
| Inyección de dependencias y BLoC (T-003) | Implementado |
| Tema Material 3 y colores por tipo (T-004) | Implementado |
| Router y shell de navegación (T-005) | Implementado |
| Cliente GraphQL con timeout y errores tipados (T-010) | Implementado |
| Contrato del repositorio y entidades del dominio | En desarrollo |
| Base de datos local con Drift (T-006 a T-008) | En desarrollo |
| Queries del catálogo y DTOs (T-011) | En desarrollo |
| Monitor de conectividad e indicador global (T-012, T-013) | En desarrollo |
| Sincronización remoto → local (T-014) | En desarrollo |
| Catálogo con estados de carga, vacío y error (T-015, T-016) | En desarrollo |
| Detalle, favoritos, búsqueda y filtros, trivia, resiliencia completa | Planificado (entrega final) |

## 1. Descripción del proyecto

La app permite consultar el catálogo de Pokémon, ver el detalle de cada uno, gestionar favoritos, buscar y filtrar, y jugar una trivia, **tanto con conexión como sin ella**.

Principios que guían el diseño:

- **Fuente de verdad local.** La interfaz solo observa la base de datos; las respuestas de la red nunca se muestran directamente.
- **Online-Preferred.** Si el servicio está disponible, se actualiza sin bloquear la navegación.
- **Degradación segura.** Un fallo remoto nunca borra datos locales válidos.
- **Transparencia.** El usuario sabe en todo momento el estado de la conexión y la vigencia de los datos.

Los datos del usuario (favoritos, resultados de trivia) viven solo en el dispositivo. PokeAPI es una fuente de solo lectura y no hay backend propio.

## 2. Requisitos de ejecución

- Flutter SDK (canal estable) con su versión de Dart. Versión usada: `[completar con la salida de flutter --version]`.
- Android SDK y un dispositivo Android físico o un emulador.
- Conexión a Internet **en la primera ejecución** para descargar el catálogo. Después funciona sin conexión.
- iOS: el código es multiplataforma, pero el equipo desarrolló en Windows y **no se pudo compilar ni probar en iOS** (ver Limitaciones).

## 3. Instrucciones de instalación

```bash
git clone https://github.com/mariajose12-alt/icc451-pokedex
cd pokedex
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # genera el código de Drift
flutter devices
flutter run -d <id-del-dispositivo>
```

Comprobaciones de calidad:

```bash
flutter analyze                          # debe salir sin advertencias
dart format --set-exit-if-changed .      # debe salir sin cambios
flutter test
```

> Android necesita el permiso `INTERNET` en `android/app/src/main/AndroidManifest.xml`. El template de Flutter solo lo trae en las compilaciones de depuración.

## 4. Tecnologías utilizadas y su justificación

| Paquete | Para qué se usa | Por qué |
|---|---|---|
| `flutter_bloc`, `equatable` | Gestión de estado | Flujo explícito evento → estado, estados comparables y fáciles de probar. Ver [ADR-0002](docs/adr/0002-bloc-y-get-it.md) |
| `get_it` | Inyección de dependencias | Contenedor simple; las dependencias llegan por constructor y son sustituibles (RNF-MAN-03) |
| `go_router` | Navegación | Rutas declarativas y shell con estado por pestaña (sin parpadeos) |
| `graphql` | Cliente GraphQL de PokeAPI | Cliente de Dart puro, sin widgets que acoplen la UI a la red. Ver [ADR-0004](docs/adr/0004-cliente-graphql.md) |
| `connectivity_plus` | Cambios de red | Avisa de cambios de red; **no** prueba que la API responda, para eso hay una verificación activa |
| `drift`, `drift_dev`, `build_runner`, `sqlite3_flutter_libs`, `path_provider`, `path` | Base de datos local | SQLite con consultas tipadas, streams reactivos e índices. Ver [ADR-0001](docs/adr/0001-drift-fuente-de-verdad.md) |
| `cached_network_image`, `flutter_cache_manager` | Imágenes en disco | Las imágenes ya vistas se ven sin conexión, con caché acotada |
| `shared_preferences` | Preferencias | Filtros y orden entre sesiones |
| `intl` | Internacionalización | Español e inglés |
| `flutter_lints` (dev) | Calidad de código | Linter estricto (`strict-casts`, `strict-inference`, `strict-raw-types`) |

Decisión sobre tipografías: **no se usa `google_fonts`**, porque descarga las fuentes por red y rompería el funcionamiento offline.

## 5. Arquitectura

Clean Architecture organizada por funcionalidades. Las dependencias apuntan hacia el dominio. Ver [ADR-0005](docs/adr/0005-clean-architecture-por-features.md).

```text
 PokeAPI (GraphQL)
        │  solo escribe en la base local
        ▼
 core/network ─► DTO + mapeador ─► Repositorio (data) ─► Drift / SQLite
                                                            │  Stream
                                                            ▼
        Contrato del repositorio (domain) ─► Bloc ─► Widget (presentation)
```

| Capa | Responsabilidad | No puede |
|---|---|---|
| `presentation` | Pantallas, widgets, Blocs, estados | Acceder al cliente GraphQL ni a la base de datos |
| `domain` | Entidades, contratos de repositorio, reglas | Depender de Flutter, GraphQL o Drift |
| `data` | Repositorios, DTO, mapeadores, fuentes de datos | Exponer DTO a la presentación |

El detalle completo del funcionamiento está en [docs/decisiones-y-funcionamiento.md](docs/decisiones-y-funcionamiento.md).

## 6. Estructura del proyecto

```text
lib/
  main.dart                      raíz de composición (registro de dependencias)
  app/
    app.dart                     MaterialApp.router
    router/                      rutas (go_router) y shell con barra de navegación
    theme/                       tema Material 3 y colores por tipo
  core/
    di/                          contenedor get_it y observador de Blocs
    network/                     cliente GraphQL, configuración y excepciones tipadas
    database/                    base Drift y tablas
    connectivity/                monitor de conectividad real
    sync/                        coordinador de sincronización
    errors/                      fallos del dominio (Failure)
  features/
    pokemon/        presentation/ domain/ data/
    favorites/      presentation/ domain/ data/
    trivia/         presentation/
    settings/       presentation/
docs/
  adr/                           registros de decisiones de arquitectura
  decisiones-y-funcionamiento.md
```

## 7. Estrategia Offline-First

**Estado: En desarrollo.**

1. La interfaz **solo** observa un `Stream` de la base local (a través del repositorio).
2. Las respuestas de GraphQL se validan y se guardan en la base; la UI se actualiza porque la base emite el cambio.
3. La app abre de inmediato (estado de carga o vacío) y nunca bloquea la navegación mientras sincroniza.
4. Sin conexión funcionan catálogo, detalle, búsqueda, filtros, favoritos y trivia con los datos ya descargados.
5. Un error remoto nunca elimina ni sobrescribe datos locales válidos.
6. El catálogo completo **no** se descarga obligatoriamente en la primera ejecución; se hace en segundo plano y de forma progresiva.

Esto no es una caché HTTP: los datos están estructurados (entidades, relaciones, índices), las consultas nuevas funcionan sin red y los datos del usuario forman parte del mismo modelo local.

## 8. Uso de GraphQL y estrategia de paginación

**Estado: cliente Implementado; queries En desarrollo.**

- Endpoint: `https://graphql.pokeapi.co/v1beta2` (solo acepta POST).
- Timeout explícito de **20 s** por solicitud.
- La caché del cliente está desactivada (`FetchPolicy.noCache`): la verdad es la base local.
- Se piden **solo los campos necesarios**. Las URLs de imagen se extraen con el argumento `path` en lugar de pedir el bloque completo de sprites.

Consulta del catálogo (paginada por cursor de id):

```graphql
query CatalogPage($lastId: Int!, $pageSize: Int!) {
  pokemon(
    where: {is_default: {_eq: true}, id: {_gt: $lastId}}
    order_by: {id: asc}
    limit: $pageSize
  ) {
    id
    name
    height
    weight
    pokemonsprites {
      artwork: sprites(path: "other.official-artwork.front_default")
      sprite: sprites(path: "front_default")
    }
    pokemontypes { slot type { id name } }
    pokemonspecy { id generation_id }
  }
  pokemon_aggregate(where: {is_default: {_eq: true}}) { aggregate { count } }
}
```

**Paginación: cursor por id, páginas de 250.** El catálogo (1025 Pokémon) se descarga en 5 llamadas, muy por debajo del límite de 100 solicitudes por hora por IP que documenta PokeAPI. Se justifica en el [ADR-0003](docs/adr/0003-sincronizacion-cursor-y-upsert.md).

Errores diferenciados (excepciones tipadas): sin conexión, timeout, límite de solicitudes, error de servidor, errores GraphQL (incluidas respuestas parciales) y errores inesperados.

## 9. Estrategia de sincronización

**Estado: Planificado (T-014, T-035, T-036, T-044).**

- Dirección única: **remoto → local**. PokeAPI es la autoridad de los datos del catálogo; los favoritos y la trivia no se sincronizan.
- Cada página se guarda en **una transacción** junto con el último id procesado (`sync_metadata`). Si se interrumpe, se reanuda desde ahí.
- Inserción con **upsert** por clave estable (id de PokeAPI): repetir la sincronización no duplica registros.
- Disparadores: al iniciar, al recuperar conectividad, al abrir un detalle, de forma periódica y por actualización manual.
- Reintentos con backoff exponencial y máximo de intentos; una sola sincronización a la vez por recurso.
- Restauración de datos alterados localmente con la versión de PokeAPI (solo catálogo, nunca favoritos ni trivia).

## 10. Persistencia local

**Estado: En desarrollo (T-006 a T-008).**

Base SQLite con Drift. Tablas del avance:

| Tabla | Clave | Índices | Notas |
|---|---|---|---|
| `pokemons` | `id` (el de PokeAPI) | `name`, `national_dex_number`, `generation_id` | Catálogo |
| `types` | `id` | — | Tipos elementales |
| `pokemon_types` | (`pokemon_id`, `slot`) | `type_id` | Relación Pokémon–tipo |
| `favorites` | `pokemon_id` | — | Datos del usuario, sin borrado en cascada |
| `sync_metadata` | `resource_key` | — | Última sincronización, estado y cursor |

Las tablas de movimientos, habilidades, evoluciones y trivia se agregan en la entrega final.

## 11. Gestión de conectividad

**Estado: En desarrollo (T-012, T-013).**

- La disponibilidad del servicio y la sincronización son **dos dimensiones independientes** y se modelan por separado.
- El estado Online se decide con una **verificación activa de la API**, no solo con la presencia de red.
- Un indicador global y fijo (en el shell de navegación) muestra el estado con texto, icono y etiqueta de accesibilidad:
  `Online` · `Offline` · `Servicio no disponible` · `Sincronizando`, además del origen y la vigencia de los datos.
- Las verificaciones se espacian para no gastar la cuota de PokeAPI.

## 12. Funcionalidades adicionales implementadas

**Estado: Planificado.** Tema oscuro, internacionalización español/inglés en toda la app, Pokémon Card compartible, animaciones Hero y microinteracciones. Se listarán aquí las que se terminen.

## 13. Limitaciones conocidas

- **Límite de PokeAPI:** 100 solicitudes por hora por IP. Si varios dispositivos comparten una red, pueden agotarla.
- **Señal del límite de solicitudes sin verificar:** se asume que PokeAPI responde con HTTP 429, pero no se pudo comprobar sin gastar la cuota.
- **Reinicio diario del servicio:** PokeAPI se reinicia a la 1:00 UTC (9 pm en República Dominicana) con unos 2 minutos sin servicio.
- **iOS no probado:** el desarrollo se hizo en Windows.
- **Primera ejecución sin Internet:** no hay datos; se muestra un estado vacío explicativo.
- El catálogo se descarga progresivamente: al inicio puede ser parcial y la interfaz lo indica.

## 14. Flujo de trabajo y calidad

- Una rama por tarea (`feature/T-xxx-descripcion`) y *pull request* revisado por la otra integrante.
- Una *issue* por tarea del plan.
- `flutter analyze` sin advertencias y `dart format` sin cambios antes de cada commit.
- Definición de hecho (DoD) en la planificación: capas respetadas, estados explícitos, accesibilidad (Semantics, contraste 4.5:1, objetivos de 48 dp, texto al 200%), pruebas offline y revisión cruzada.

## 15. Declaración de uso de herramientas de IA

El equipo utilizó **Claude (Anthropic)** como asistente para analizar los requisitos, planificar las tareas, revisar decisiones de arquitectura y generar borradores de código y documentación. El equipo revisó el material generado, lo adaptó al proyecto y **es responsable de todo el código entregado y puede explicar cualquier parte de él**.

> Nota para el equipo: ajusten este párrafo a lo que realmente hayan hecho; el enunciado exige declarar el uso de IA o de código de terceros (§17.6).

## 16. Documentación

- [Decisiones y funcionamiento](docs/decisiones-y-funcionamiento.md)
- [Registros de decisiones de arquitectura (ADR)](docs/adr/README.md)

## Créditos y aviso legal

Proyecto académico sin fines comerciales. Los datos provienen de [PokéAPI](https://pokeapi.co). Pokémon y sus marcas pertenecen a sus respectivos propietarios.
