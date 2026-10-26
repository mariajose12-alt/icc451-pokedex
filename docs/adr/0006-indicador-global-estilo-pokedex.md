# ADR-0006: Indicador global con forma de lente y luces de Pokédex

- **Estado:** Aceptado
- **Fecha:** 2026-10-26
- **Decidido por:** María

## Contexto

El enunciado exige un indicador global, fijo, visible y reactivo (PF §7). Debe estar en todas las pantallas principales (IND-01), reflejar la disponibilidad real del servicio (IND-02), actualizarse solo (IND-03), mostrar el origen y la vigencia de los datos (IND-04), no depender solo del color (IND-05), evitar parpadeos (IND-06) y no bloquear la navegación al sincronizar (IND-07). El mockup del enunciado es solo una referencia conceptual: el diseño es decisión del equipo.

La interfaz de la app imita una Pokédex (estilo pixelado, carcasa roja). María quiso que el indicador fuera parte de ese diseño y no un elemento ajeno, como un aviso genérico.

## Decisión

1. **Un solo widget** (`ConnectivityIndicator`) colocado en el `AppShell`, encima de las pestañas. Así aparece en todas las pantallas principales y en la misma posición (IND-01).
2. **Forma:** un **lente azul** con un icono dentro, una cápsula con **tres luces** (roja, amarilla y verde), un título y una línea de detalle con el origen y la vigencia de los datos. Todo sobre el **rojo de la carcasa**, con texto blanco (contraste de unos 5,2:1, por encima del 4,5:1 de RNF-ACC-02).
3. **Cada estado tiene su combinación:**

   | Estado | Icono del lente | Luz encendida | Título |
   |---|---|---|---|
   | Online | nube con check | verde | En línea |
   | Offline | nube tachada | roja | Sin conexión |
   | Servicio no disponible | advertencia | amarilla | Servicio no disponible |
   | Sincronizando | flechas circulares | verde | Sincronizando… |
   | Verificando | reloj de arena | ninguna | Verificando… |

4. **El color nunca es la única señal** (IND-05): cada estado comunica lo mismo con el icono, el texto y la posición de la luz (izquierda, centro o derecha). Además, una etiqueta `Semantics` con región «en vivo» se lee de corrido y avisa de los cambios.
5. **Dos dimensiones separadas** (PF §7.4): un `ConnectivityIndicatorCubit` recibe la disponibilidad del servicio (del monitor, ver [ADR-0007](0007-monitor-de-conectividad-verificacion-activa.md)) y la información de sincronización (`SyncInfoSource`: si sincroniza y cuándo fue la última vez) por canales distintos. «Sincronizando» solo se muestra si el servicio está Online, para no presentar estados contradictorios.
6. **Ventana de estabilidad de 1200 ms** (IND-06): un cambio de disponibilidad solo se muestra si se mantiene durante ese tiempo. Si la red cae y vuelve antes, el usuario no ve nada. La **primera respuesta real se muestra sin esperar**, porque no hay un estado anterior que pueda parpadear. El valor es un parámetro del Cubit y se puede ajustar.
7. **Sincronización no intrusiva** (IND-07): el lente late despacio (ciclo de 1,4 s) mientras se sincroniza. No hay barras ni bloqueos, y la navegación sigue funcionando. Si el sistema tiene activada la opción de reducir animaciones, el lente se queda quieto.
8. **Se retira la barra de título de cada pantalla.** El indicador pasa a ser el único encabezado, y la pestaña activa de la navegación inferior (icono y texto) identifica la pantalla.
9. **Textos en los archivos ARB** (español e inglés), sin texto fijo en el widget.

## Alternativas consideradas

1. **Un aviso o banner temporal (Snackbar).** Desaparece, así que no cumple «fijo y visible» (IND-01).
2. **Un chip de color con texto en la barra superior.** Cumple los requisitos, pero se ve ajeno al diseño de Pokédex y depende más del color.
3. **Una barra de progreso lineal para sincronizar.** Es más intrusiva y ocupa espacio extra. El lente que late comunica lo mismo sin añadir elementos.
4. **Mostrar solo luces de colores.** Es lo más fiel a una Pokédex, pero incumple IND-05 porque dependería del color.

## Consecuencias

**A favor**
- El indicador forma parte de la identidad visual de la app.
- Cumple IND-01 a IND-07 sin depender del color.
- La lógica (Cubit) está separada del dibujo (widget), así que se prueba sin pantalla.
- Cambiar el diseño del indicador no toca el monitor ni la sincronización.

**En contra**
- Ocupa una altura fija (unos 70 dp) en todas las pantallas principales.
- La ventana de 1200 ms retrasa hasta ese tiempo la visibilidad de un cambio real.
- Con el texto del sistema al 200 % la fila de título y luces se aprieta. Debe comprobarse en el emulador (DoD 7, RNF-ACC-04).
- Mientras no exista el sincronizador (T-014), la información de sincronización viene de una fuente falsa: la hora de la última sincronización aparece como «sin sincronizar».

**Requisitos relacionados:** IND-01 a IND-07, RNF-ACC-01 a RNF-ACC-05, PA-07, PA-08.
