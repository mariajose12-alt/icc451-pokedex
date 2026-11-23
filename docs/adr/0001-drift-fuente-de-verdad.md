# ADR-0001: Drift (SQLite) como fuente de verdad de la interfaz

- **Estado:** Aceptado
- **Fecha:** 2026-10-21
- **Decidido por:** María y Almy

## Contexto

La app debe funcionar con y sin Internet (OF-05 a OF-10). PokeAPI es una fuente de solo lectura, limita su API GraphQL a 100 solicitudes por hora por IP y pide guardar los datos en caché local. El enunciado exige que la interfaz observe la persistencia local y no respuestas de red (OF-16, OF-17), que búsquedas, filtros y orden funcionen sobre datos locales (OF-06, RNF-REN-02) y que los datos del usuario (favoritos, trivia) vivan en el mismo modelo local (§6.5).

## Decisión

Usaremos **Drift sobre SQLite** como fuente de verdad. La interfaz observa *Streams* de Drift a través de repositorios. Las respuestas de GraphQL se validan y se guardan en transacciones con *upsert*; nunca se muestran directamente en pantalla.

- La clave primaria de cada entidad del catálogo es el **id de PokeAPI** (estable entre sincronizaciones).
- Favoritos y resultados de trivia están en **tablas independientes del catálogo y sin borrado en cascada**, para que la sincronización no pueda afectarlos (PS-11, OF-21).
- Se definen índices por nombre, número de Pokédex y generación para las consultas de búsqueda y filtro.

## Alternativas consideradas

1. **Caché HTTP o caché normalizada del cliente GraphQL.** Descartada: solo responde a solicitudes idénticas ya hechas, no permite consultas nuevas sin red, puede descartar datos válidos por vencimiento y deja fuera los datos del usuario (§6.5).
2. **SQLite directo con `sqflite`.** Mismo motor, pero con consultas escritas como texto, sin verificación de tipos y sin *streams* reactivos listos.
3. **Base NoSQL (por ejemplo Hive o Isar).** Permite guardar objetos, pero el modelo es relacional (Pokémon–tipo de muchos a muchos) y los filtros combinados (tipo + generación + búsqueda + orden) encajan mejor en consultas SQL con índices.

## Consecuencias

**A favor**
- La interfaz se actualiza sola con las consultas reactivas (`watch`).
- Consultas tipadas e índices documentados.
- *Upsert* por clave estable: sincronizar varias veces no duplica registros.
- Migraciones de esquema versionadas.

**En contra**
- Generación de código con `build_runner` y curva de aprendizaje.
- Hay que mantener el esquema, las migraciones y los mapeadores (DTO, fila y entidad).
- SQLite trae las claves foráneas desactivadas: hay que activarlas al abrir la base.
- Usar `insertOrReplace` borraría y reinsertaría filas; **está prohibido** en el catálogo y se usa `insertOnConflictUpdate`.

**Requisitos relacionados:** OF-16, OF-17, OF-18, OF-21, PS-01, PS-05, PS-06, PS-11, RNF-REN-02.
