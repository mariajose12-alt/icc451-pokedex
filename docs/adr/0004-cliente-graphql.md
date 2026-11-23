# ADR-0004: Cliente GraphQL de Dart puro, sin caché y con errores tipados

- **Estado:** Aceptado
- **Fecha:** 2026-10-23
- **Decidido por:** María y Almy

## Contexto

La planificación mencionaba `ferry` o `graphql_flutter`. El enunciado exige que los widgets no dependan directamente de respuestas GraphQL (OF-17), timeouts explícitos (RNF-RES-01) y manejo diferenciado de pérdida de conectividad, timeout, errores GraphQL (incluidas respuestas parciales) y limitación de tasa (RNF-RES-05). PokeAPI limita a 100 solicitudes por hora por IP.

## Decisión

1. Usar el paquete **`graphql`** (Dart puro), envuelto en una clase propia `PokeApiClient` que recibe la **URL y el timeout por constructor**.
2. **`FetchPolicy.noCache`** en todas las consultas: la verdad es la base local, no la caché del cliente.
3. **Timeout de 20 segundos**, documentado, aplicado con `Future.timeout`.
4. **Excepciones tipadas** (`sealed class PokeApiException`): `NoConnectionException`, `RequestTimeoutException`, `RateLimitException`, `ServerErrorException`, `GraphQlResponseException` (con datos parciales si los hay) y `UnexpectedNetworkException`.
5. El cliente **no** traduce a fallos del dominio: eso lo hace la capa `data` (RNF-CAL-03).
6. Se asume que el límite de solicitudes llega como **HTTP 429**. Es una suposición sin verificar (ver Consecuencias).

## Alternativas consideradas

1. **`graphql_flutter`.** Añade widgets (`Query`, `Mutation`) con los que la interfaz consumiría GraphQL directamente, lo que OF-17 prohíbe.
2. **`ferry`.** Tipado fuerte por generación de código, pero suma otra herramienta de generación a la de Drift y su normalización de caché compite con la base local.
3. **`http` con POST manual.** Máximo control, pero reimplementar el protocolo y el análisis de errores no aporta valor para este proyecto.

## Consecuencias

**A favor**
- La UI queda aislada de GraphQL.
- El simulador de caída de API (PA-08) solo necesita apuntar el cliente a otra URL.
- Cada tipo de fallo se puede mostrar de forma distinta.
- Una clase falsa puede sustituir al cliente en pruebas.

**En contra**
- Sin caché del cliente: toda lectura remota consume cuota.
- No se pudo verificar cómo señala PokeAPI el límite de solicitudes (HTTP 429 o error GraphQL) sin gastar la cuota; queda como limitación conocida.
- El timeout fijo de 20 s puede ser largo en redes muy lentas.

**Requisitos relacionados:** OF-17, OE-02, RNF-RES-01, RNF-RES-05, RNF-CAL-03, PA-08.
