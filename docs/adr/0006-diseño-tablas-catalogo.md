# ADR-0006: Persistencia local con Drift (SQLite) como fuente de verdad

- **Estado:** Aceptado
- **Fecha:** 2026-10-26
- **Decidido por:** Almy y María

## Contexto

El enunciado exige una base de datos local estructurada que sea la fuente de lectura de la interfaz (OF-16), con consultas sobre entidades y relaciones, búsquedas y filtros sin conexión (OF-06, RF-FIL-05), y favoritos y trivia en el mismo modelo local (§6.5). Una caché de respuestas HTTP no cumple: no permite consultar por campos ni relacionar entidades.

## Decisión

Usar **Drift** sobre **SQLite**, con `NativeDatabase.createInBackground` para no bloquear la interfaz (RNF-REN-03).

El modelo sigue el Diagrama 6 del enunciado:

- Catálogo: `pokemons`, `poke_types`, `abilities`, y las relaciones `pokemon_types` y `pokemon_abilities`.
- Datos del usuario y sincronización: `favorites`, `trivia_results`, `trivia_answers` y `sync_metadata`.

Reglas del modelo:

- Las claves primarias de catálogo vienen de PokeAPI (`id`), no son autoincrementales (PS-05).
- Las relaciones usan claves compuestas y `ON DELETE CASCADE` (PS-06).
- `PRAGMA foreign_keys = ON` se activa en `beforeOpen`, porque SQLite lo desactiva por defecto.
- `favorites` no tiene cascada hacia `pokemons`: la sincronización del catálogo nunca debe afectar datos del usuario (PS-11).
- La tabla de Pokémon se llama `pokemons` (clase `Pokemons`) para no chocar con la entidad de dominio `Pokemon`.

## Alternativas consideradas

1. **Caché HTTP (`dio_cache_interceptor` o similar).** Simple, pero solo responde a solicitudes idénticas ya guardadas. No permite búsquedas ni filtros sobre datos locales, y el TTL puede descartar datos válidos (§6.5).
2. **Caché normalizada del cliente GraphQL (`graphql_flutter`).** Complementa la solución, pero no sustituye la persistencia estructurada exigida en OF-16 y no guarda favoritos ni trivia.
3. **Hive o Isar.** Almacenamiento clave-valor u orientado a objetos. Rápido para lectura, pero sin relaciones ni consultas SQL, así que las búsquedas por tipo y generación tendrían que hacerse en memoria.
4. **SharedPreferences o archivos JSON.** Adecuado para configuración, no para miles de registros con relaciones.

## Consecuencias

**A favor**
- Búsquedas, filtros y ordenaciones sobre datos locales con índices (RNF-REN-02).
- Transacciones que evitan datos parciales si la sincronización se interrumpe (RNF-RES-04).
- Un solo modelo para catálogo, favoritos y trivia.
- `schemaVersion` y `MigrationStrategy` preparados para cambios futuros (PS-10).

**En contra**
- Requiere `build_runner` y código generado (`.g.dart`) que no se edita a mano.
- La conversión entre filas y entidades de dominio añade código de mapeo (ver ADR-0005).

**Requisitos relacionados:** OF-16, OF-17, OF-06, OF-10, RF-FIL-05, RNF-REN-02, RNF-REN-03, RNF-RES-04, PS-01, PS-05, PS-06, PS-10, PS-11, D6.