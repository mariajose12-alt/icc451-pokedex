# Registros de decisiones de arquitectura (ADR)

Cada archivo documenta una decisión importante con su contexto, la decisión, las alternativas consideradas y las consecuencias.

| ADR | Decisión | Estado |
|---|---|---|
| [0001](0001-drift-fuente-de-verdad.md) | Drift (SQLite) como fuente de verdad de la interfaz | Aceptado |
| [0002](0002-bloc-y-get-it.md) | BLoC para el estado y `get_it` con inyección por constructor | Aceptado |
| [0003](0003-sincronizacion-cursor-y-upsert.md) | Sincronización con cursor por id, páginas de 250 y upsert | Aceptado |
| [0004](0004-cliente-graphql.md) | Cliente GraphQL de Dart puro, sin caché, con errores tipados | Aceptado |
| [0005](0005-clean-architecture-por-features.md) | Clean Architecture organizada por funcionalidades | Aceptado |
| [0006](0006-diseño-tablas-catalogo.md) | Persistencia local con Drift: modelo de tablas y reglas | Aceptado |
| [0007](0007-implementacion-tablas-favoritos-results-sync-metadata.md) | Datos del usuario y estado de sincronización en tablas separadas del catálogo | Aceptado |
| [0008](0008-dao-catalogo-streams-y-transacciones.md) | DAO del catálogo con streams reactivos y escritura transaccional por página | Aceptado |
| [0009](0009-cache-persistence-imagenes-respaldo-offline.md) | Caché persistente de imágenes con respaldo offline | Aceptado |
| [0010](0010-indicador-global-estilo-pokedex.md) | Indicador global con forma de lente y luces de Pokédex | Aceptado |
| [0011](0011-monitor-de-conectividad-verificacion-activa.md) | Monitor de conectividad con verificación activa de la API | Aceptado |
| [0012](0012-sincronizador-en-la-capa-data.md) | Sincronizador del catálogo en la capa data | Aceptado |

Estados posibles: **Propuesto**, **Aceptado**, **Reemplazado**. Si una decisión cambia, no se borra su ADR: se marca como reemplazado y se crea uno nuevo.

Las decisiones de persistencia y sincronización que el enunciado numera como PS-01 a PS-12 están en [persistencia-y-sincronizacion.md](../persistencia-y-sincronizacion.md).
