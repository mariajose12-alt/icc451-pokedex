# ADR-0002: BLoC para el estado y get_it con inyección por constructor

- **Estado:** Aceptado
- **Fecha:** 2026-10-21
- **Decidido por:** María y Almy

## Contexto

El enunciado exige una gestión de estado estructurada y reactiva que modele de forma explícita los estados de carga, éxito, error y ausencia de datos (OE-06), y dependencias inyectadas y sustituibles (RNF-MAN-03). Recomienda Riverpod o BLoC. La planificación inicial mencionaba Riverpod; el equipo eligió BLoC. Motivo del equipo: `[completar con la razón real]`.

## Decisión

1. **BLoC / Cubit** para la gestión de estado.
   - **Cubit** para lo simple (estado de conexión, alternar un favorito).
   - **Bloc con eventos** para flujos que lo necesitan, como el catálogo (búsqueda con *debounce*, filtros, refresco).
   - Los estados son clases selladas con `equatable`: `Initial`, `Loading`, `Success`, `Empty` y `Failure`.
2. **`get_it`** como contenedor de dependencias, con una regla estricta:
   - Solo la **raíz de composición** (`main.dart` y los providers de `app/`) puede usar `getIt`.
   - Los Blocs y repositorios reciben sus dependencias **por constructor**; ninguno llama a `getIt` por dentro.
3. **Registro contra abstracciones:** los repositorios se registran con el contrato del dominio, no con la implementación.
4. **Ciclo de vida:** singleton para la base de datos, el cliente GraphQL, el monitor de conectividad, el coordinador de sincronización y los repositorios; un Bloc nuevo por pantalla, salvo el de conectividad, que vive en la raíz porque lo usa el indicador global.
5. Un `BlocObserver` imprime los cambios de estado en consola para depurar el flujo Offline-First.

## Alternativas consideradas

1. **Riverpod.** Válido y recomendado por el enunciado, y trae su propia inyección. Descartado por decisión del equipo a favor de BLoC.
2. **Provider o `setState`.** No obligan a modelar estados ni eventos de forma explícita y mezclan lógica con widgets.
3. **`injectable` (generación de código sobre `get_it`).** Reduce el registro manual, pero agrega otra capa de generación de código. Se puede adoptar más adelante si el registro crece.
4. **Inyección solo por constructores, sin contenedor.** Es lo más puro, pero requiere pasar dependencias por muchas capas de widgets.

## Consecuencias

**A favor**
- El flujo evento → estado es explícito y fácil de seguir en consola.
- Cualquier dependencia se puede sustituir por una falsa en pruebas, porque nada usa el contenedor por dentro.
- La presentación no conoce la implementación de los datos.

**En contra**
- Más código repetitivo (eventos, estados, Bloc).
- `get_it` es un *service locator*: si alguien lo llama dentro de un Bloc, se pierde la sustituibilidad. Se controla con la regla de arriba y con revisión en los PR.
- Todo el registro está secuencial en `main()`; cuando crezca se dividirá por módulos.

**Requisitos relacionados:** OE-06, RNF-MAN-02, RNF-MAN-03, RF-CAT-04.
