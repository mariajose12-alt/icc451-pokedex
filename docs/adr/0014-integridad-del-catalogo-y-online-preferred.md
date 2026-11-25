# ADR-0014: Comprobación de integridad del catálogo y política Online-Preferred

- **Estado:** Propuesto
- **Fecha:** 2026-11-25
- **Decidido por:** María

## Contexto

El enunciado pide que la app sea **Offline-First con Online-Preferred**: si hay conexión, se prioriza traer datos frescos de PokeAPI y guardarlos (P-02). También pide detectar y restaurar datos del catálogo alterados localmente (OF-19, OF-20, OF-21, PS-12, PA-16).

La pantalla solo lee de Drift (OF-16, OF-17). Leer datos remotos directamente en la interfaz rompería esa regla, así que «preferir lo online» tiene que significar **escribir antes y con más frecuencia en la base**, no cambiar la fuente de lectura. La vigencia de 24 h (catálogo) y 7 días (detalle) del [PS-03](../persistencia-y-sincronizacion.md) era demasiado larga para que lo online se note.

## Decisión

1. **La interfaz sigue leyendo solo de la base.** Con conexión, la red solo escribe en Drift y la pantalla se actualiza porque observa la base.
2. **Vigencias cortas para priorizar lo online:**
    - Catálogo: `defaultCatalogMaxAge` = **10 minutos**.
    - Detalle: `defaultMinInterval` = **10 segundos** entre sincronizaciones del mismo Pokémon.
    - Periódica: cada **15 minutos** mientras haya servicio (sin cambios).
3. **Restauración por sobrescritura (OF-19).** Cada sincronización hace upsert de todos los campos del catálogo con el dato de PokeAPI. Ante un conflicto prevalece el remoto.
4. **Detección y registro (OF-20).** Antes de guardar el detalle, `PokemonDetailLocalDataSource` compara nombre y tipos locales con los remotos. Si difieren, escribe en el log `Integridad: #id difiere de PokeAPI (...)` y luego restaura. La detección es solo informativa: la restauración ocurre igual.
5. **Los datos del usuario no se tocan (OF-21).** Favoritos, trivia y logros están en tablas propias y la sincronización nunca escribe en ellas.
6. **Disparadores:** al iniciar (`onlyIfStale`), al reconectar (separación mínima de 2 min), al abrir el detalle y periódico.

## Alternativas consideradas

1. **Leer de la red cuando hay conexión y de la base si no.** Es la lectura más literal de «online preferido», pero rompe OF-16/17 (calificación Insuficiente) y deja dos caminos de datos que probar.
2. **Hash por registro y escritura solo de los distintos.** Ahorra escrituras, pero añade complejidad que 1025 filas no justifican. PS-12 acepta la sobrescritura.
3. **Mantener 24 h / 7 días.** Gasta menos cuota, pero con esa vigencia la app casi nunca se comporta como Online-Preferred y una alteración tarda horas en corregirse.
4. **Vigencia de segundos para el catálogo completo.** Son 5 llamadas por sincronización y la cuota es de 100 por hora, así que se agotaría rápido.

## Consecuencias

**A favor**
- Se cumple Online-Preferred sin romper la regla de leer solo de la base.
- Una alteración local se corrige al abrir el detalle (hasta 10 s de separación) o en la siguiente sincronización del catálogo.
- La alteración queda registrada, lo que sirve para la demostración de PA-16.

**En contra**
- Más sincronizaciones consumen más de la cuota de 100 solicitudes por hora. Lo amortiguan el deduplicado de solicitudes en curso y los reintentos de 2, 4 y 6 s.
- La detección con registro cubre hoy el **detalle**. La del catálogo completo (`savePage`) queda pendiente hasta integrar la rama de búsqueda y filtros; mientras tanto el catálogo se restaura por sobrescritura sin registro.
- Se compara solo nombre y tipos, no cada campo.

**Pruebas:** `test/features/pokemon/data/integrity_detection_test.dart` (nombre alterado, sin alteración y tipo alterado) y `pokemon_detail_sync_test.dart` (restauración sin tocar favoritos, PA-16).

**Requisitos relacionados:** OF-16, OF-17, OF-19, OF-20, OF-21, PS-03, PS-04, PS-12, PA-16, P-02.