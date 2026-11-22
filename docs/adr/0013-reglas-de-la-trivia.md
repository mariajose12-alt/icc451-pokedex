# ADR-0013: Reglas de la trivia y logros calculados desde el historial

**Estado:** Propuesto
**Requisitos:** RF-TRV-01..06, OF-09, OF-21, PA-11, PA-15, RNF-MAN-02

## Contexto

La trivia debe funcionar sin conexión con los Pokémon guardados en la base
local, mostrar puntaje y ranking, y tener logros. El enunciado pide estas
funciones pero no fija los números (cuántas preguntas, cuánto tiempo, cuántos
puntos), así que el equipo debe definirlos y poder explicarlos.

## Decisión

**Partida.** 10 preguntas de 15 segundos, con Pokémon al azar del catálogo
local. Si hay menos de 20 Pokémon guardados no se puede jugar y se muestra un
estado explicativo (PA-11, PA-15).

**Respuesta.** El usuario escribe el nombre. Se compara sin mayúsculas,
acentos, espacios ni signos ("Mr. Mime" = "mr-mime"). Un nombre incorrecto
termina la pregunta.

**Puntos por pregunta.**
- Acierto: 100 base + hasta 50 de bonus por rapidez, proporcional al tiempo
  que sobró.
- Cada pista (máximo 3, revelan letras iniciales, nunca el nombre completo)
  resta 20.
- Fallo, saltar o tiempo agotado: 0 puntos y se reinicia la racha.
- El total de una pregunta nunca es negativo.

**Logros (8).** Primera partida, Racha (5 seguidas), Relámpago (acierto en
menos de 3 s), Experto (1 000 puntos), Perfecto (10 de 10), Sin pistas (7 o
más aciertos sin pistas), Entrenador (50 aciertos en total) y Coleccionista
(25 partidas).

**Dónde viven las reglas.** En `TriviaRules` y en funciones puras de dominio
(sin Flutter ni Drift). Los textos de los logros toman sus números de ahí.

**Persistencia.** Se guarda cada partida (resultado y una fila por respuesta
con tiempo, pistas y puntos) y solo la *fecha* de desbloqueo de cada logro.
El avance (por ejemplo 12/50) y las estadísticas se calculan siempre desde el
historial. La partida y sus logros nuevos se guardan en una sola transacción.
La racha continúa entre partidas y un fallo la reinicia.

## Alternativas consideradas

- **Guardar contadores de logros** (aciertos totales, mejor racha): dos
  fuentes de verdad que se pueden desincronizar. Se descartó.
- **Opciones múltiples:** el requisito lo permite, pero el diseño aprobado usa
  nombre escrito porque hace más difícil el azar y encaja con las pistas.
- **Guardar la partida a medias:** más estados que defender y más casos de
  borde. Salir de la partida no guarda nada.
- **Reglas dentro del cubit:** más difíciles de probar y de explicar.

## Consecuencias

- Las reglas se prueban con tests puros y sin pantalla.
- Cambiar un número (tiempo, puntos, umbral) es un cambio en `TriviaRules`; el
  texto de los logros se actualiza solo.
- Las estadísticas se recalculan leyendo todas las respuestas. Con el uso
  esperado (cientos de partidas) es barato; si creciera, se podría guardar un
  resumen por partida.
- Los datos de trivia no los toca la sincronización del catálogo (OF-21).