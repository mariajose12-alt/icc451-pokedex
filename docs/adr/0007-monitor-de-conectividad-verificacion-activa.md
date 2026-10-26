# ADR-0007: Monitor de conectividad con verificación activa de la API

- **Estado:** Aceptado
- **Fecha:** 2026-10-26
- **Decidido por:** María

## Contexto

El enunciado pide que el estado de conexión salga de la **disponibilidad real del servicio GraphQL** y no solo de la detección de Wi-Fi o datos móviles (IND-02, OF-11). También exige distinguir «sin red» de «hay red pero la API no responde» (Diagrama 3, PA-07, PA-08) y comprobar la disponibilidad al iniciar, al recuperar la conectividad, al abrir un detalle y de forma periódica (OF-20, PS-04).

PokeAPI limita el uso a **100 solicitudes por hora por IP**, así que verificar el servicio con frecuencia puede agotar la cuota que necesita la sincronización.

## Decisión

1. **Contrato `ConnectivityMonitor`** (`current`, `watch()`, `start()`, `checkNow()`, `dispose()`). La interfaz y los Blocs dependen del contrato, no de la implementación (RNF-MAN-03). `watch()` emite el estado actual de inmediato y luego cada cambio.
2. **Implementación `ApiConnectivityMonitor`**, que combina `connectivity_plus` (aviso de cambios de red) con una consulta real al cliente GraphQL.
3. **Cuatro estados** (`ServiceAvailability`): `checking`, `online`, `offline` y `serviceUnavailable`.
4. **Cada comprobación sigue estos pasos:**
   1. Si `connectivity_plus` indica que no hay red, el estado es **Offline** y **no se llama a la API**.
   2. Si hay red, se ejecuta una consulta mínima: `query { pokemon(limit: 1) { id } }`. Se probó en la consola el 2026-10-26 y devuelve el Pokémon con id 1.
   3. Si responde, el estado es **Online**.
   4. Si falla por cualquier motivo (`PokeApiException`: timeout, límite de solicitudes, error del servidor, error GraphQL), el estado es **Servicio no disponible**.
5. **Offline lo decide solo `connectivity_plus`.** Una API caída con red activa nunca produce Offline: el enunciado exige mostrar «Servicio no disponible» (PA-08).
6. **Nunca Online por defecto.** El resultado inicial de cada comprobación es «Servicio no disponible» y solo pasa a Online si la consulta termina sin error.
7. **Programación de las comprobaciones:**

   | Estado | Siguiente comprobación |
   |---|---|
   | Online | a los **5 minutos** |
   | Servicio no disponible | a los **30 s**, luego **1 min**, **2 min** y **5 min** (tope) |
   | Offline | ninguna: se espera el evento de cambio de red |

   Además, cada cambio de red dispara una comprobación inmediata, y `checkNow()` permite forzarla (por ejemplo, al abrir el detalle de un Pokémon, OF-20). Los tiempos fueron aprobados por María el 2026-10-26.
8. **Solo se emite un estado cuando cambia**, y **nunca hay dos comprobaciones a la vez**. «Verificando» existe solo como estado inicial, para que el indicador no parpadee (IND-06).

## Alternativas consideradas

1. **Usar solo `connectivity_plus`.** Es simple, pero un Wi-Fi sin Internet o una API caída mostrarían Online. Incumple IND-02.
2. **Consultar la API cada pocos segundos.** Detecta los cambios antes, pero agotaría la cuota de 100 solicitudes por hora.
3. **Reintento fijo cada 30 s, como en el mockup del enunciado.** Serían 120 llamadas por hora, más que toda la cuota. Se usa un intervalo creciente con tope de 5 minutos.
4. **Usar la propia sincronización como única señal.** No gasta llamadas extra, pero no detecta la recuperación del servicio si no hay nada que sincronizar y mezcla las dos dimensiones que el enunciado pide separar (§7.4).
5. **Verificar un endpoint distinto del GraphQL.** El requisito habla de la disponibilidad del servicio GraphQL, que es el que usa la app.

## Consecuencias

**A favor**
- Con el servicio en línea se gastan como máximo **12 llamadas por hora** (más una al arrancar), frente a las 100 disponibles. La descarga completa del catálogo son 5.
- El estado Online solo se muestra cuando la API respondió de verdad.
- La recuperación es automática: al volver la red, el estado pasa de Offline a Online sin intervención del usuario (PA-07).
- El contrato permite probar el indicador con un monitor falso.

**En contra**
- Un **Wi-Fi sin Internet** se muestra como «Servicio no disponible» y no como «Sin conexión», porque `connectivity_plus` no lo distingue de una API caída.
- Con el servicio en línea, una caída puede tardar **hasta 5 minutos** en reflejarse si no hay otra actividad de red.
- Cada comprobación consume una llamada de la cuota compartida con la sincronización.
- Para demostrar PA-08 hace falta poder apuntar el cliente a una URL inválida con la red activa. Ese simulador se implementa en T-038.
- Cómo señala PokeAPI el límite de solicitudes no está verificado (se asume HTTP 429). Mientras tanto, cualquier error se trata como «Servicio no disponible».

**Pruebas:** `test/core/connectivity/api_connectivity_monitor_test.dart` cubre cuatro casos: sin red (Offline y sin llamar a la API), API que responde (Online), API caída (Servicio no disponible, nunca Online) y recuperación automática al volver la red.

**Requisitos relacionados:** IND-02, IND-03, OF-11, OF-20, PS-04, RNF-RES-02, RNF-MAN-03, PA-07, PA-08.
