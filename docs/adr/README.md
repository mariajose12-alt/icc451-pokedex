# Registros de decisiones de arquitectura (ADR)

Cada archivo documenta una decisión importante con su contexto, la decisión, las alternativas consideradas y las consecuencias.

| ADR | Decisión | Estado |
|---|---|---|
| [0001](0001-drift-fuente-de-verdad.md) | Drift (SQLite) como fuente de verdad de la interfaz | Aceptado |
| [0002](0002-bloc-y-get-it.md) | BLoC para el estado y `get_it` con inyección por constructor | Aceptado |
| [0003](0003-sincronizacion-cursor-y-upsert.md) | Sincronización con cursor por id, páginas de 250 y upsert | Propuesto |
| [0004](0004-cliente-graphql.md) | Cliente GraphQL de Dart puro, sin caché, con errores tipados | Aceptado |
| [0005](0005-clean-architecture-por-features.md) | Clean Architecture organizada por funcionalidades | Aceptado |

Estados posibles: **Propuesto**, **Aceptado**, **Reemplazado**. Si una decisión cambia, no se borra su ADR: se marca como reemplazado y se crea uno nuevo.
