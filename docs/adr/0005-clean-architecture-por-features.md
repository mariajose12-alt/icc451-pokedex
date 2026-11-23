# ADR-0005: Clean Architecture organizada por funcionalidades

- **Estado:** Aceptado
- **Fecha:** 2026-10-23
- **Decidido por:** María y Almy

## Contexto

El enunciado exige una arquitectura por funcionalidades con separación de capas, dependencias hacia el dominio y bajo acoplamiento (RNF-MAN-01, RNF-MAN-02, OE-01). Los widgets no deben acceder al cliente GraphQL ni a la base de datos (OF-17).

## Decisión

Organizar `lib/` en `app/`, `core/` y `features/<funcionalidad>/{presentation,domain,data}`. Reglas de dependencia:

- `domain` **no** importa Flutter, `graphql` ni `drift`.
- `presentation` **no** importa `data` ni `core/database` ni `core/network`; solo habla con el dominio.
- `data` implementa los contratos del dominio y es la única que conoce Drift y GraphQL.
- Cada capa tiene sus propios modelos (DTO en red, filas en la base, entidades en el dominio) y los mapeadores los convierten; los DTO no llegan a la presentación.
- `core/` es de uso común pero no se convierte en un depósito de lógica de una sola funcionalidad.

El equipo puede verificar la regla buscando importaciones prohibidas en `domain` y `presentation`.

## Alternativas consideradas

1. **Estructura por capas (`models/`, `views/`, `services/`).** Más simple al inicio, pero las funcionalidades quedan dispersas y es fácil que la UI llegue directo a los datos.
2. **Lógica dentro de los widgets.** Rápido, pero imposible de probar y contradice el enunciado.

## Consecuencias

**A favor**
- Responsabilidades claras y dependencias explícitas.
- Cada funcionalidad se puede entender y cambiar de forma aislada.
- Permite sustituir cualquier implementación por una falsa, y avanzar la interfaz mientras la capa de datos se termina.

**En contra**
- Más archivos y código de mapeo (entidad, fila, DTO).
- Hay que revisar en los PR que nadie rompa la regla de dependencia.

**Requisitos relacionados:** OE-01, OF-17, OF-18, RNF-MAN-01, RNF-MAN-02, RNF-MAN-03.
