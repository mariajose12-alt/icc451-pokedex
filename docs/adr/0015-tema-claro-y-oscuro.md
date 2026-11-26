# ADR-0015: Tema claro y oscuro con ThemeExtension

- **Estado:** Aceptado
- **Fecha:** 2026-11-25
- **Decidido por:** María

## Contexto

El enunciado recomienda temas claro y oscuro (RF-COM-06). La interfaz «Pokédex pixelada» nació solo oscura, con los colores fijos en `PixelPalette` (unos 200 usos en 34 archivos). La propuesta de dejarla solo oscura (P-09) nunca se confirmó y queda reemplazada por esta decisión.

## Decisión

1. **`PixelColors` es un `ThemeExtension`** con una versión clara y otra oscura. Los widgets lo leen con `context.pixel`.
2. **Tres opciones en Ajustes:** claro, oscuro o seguir al sistema. La elección se guarda en `SharedPreferences` (`ThemeModeCubit`), igual que el idioma.
3. **Tokens de texto propios.** El amarillo como relleno sirve en ambos temas, pero como texto sobre blanco no se lee (1.5:1). Por eso existen `accentText` (ámbar oscuro en el tema claro) y `onAccent` (texto sobre el relleno amarillo).
4. **Contraste comprobado por test.** `pixel_colors_contrast_test.dart` verifica 15 pares de colores por tema, todos con al menos 4.5:1 (RNF-ACC-02).
5. **Partes que no cambian con el tema:** el lente y las luces del indicador y el header del detalle (van sobre la carcasa roja o sobre el color del tipo). La trivia sigue el tema elegido. Solo su escenario (el fondo azul con rayos y los textos que van encima) se mantiene oscuro en claro y oscuro, como el encabezado del detalle, porque es una escena y sus textos blancos necesitan fondo oscuro.
7. **Mapa de regiones con dos versiones:** el mar del mapa (ADR-0016) tiene una versión clara y otra oscura, para que en el tema claro no haga un contraste tan fuerte con el resto de la pantalla.
6. **`context.pixel` tiene respaldo:** si el tema no trae `PixelColors`, usa el oscuro. Así los widgets funcionan en pruebas sin el tema de la app.

## Alternativas consideradas

1. **Solo oscuro, justificado.** Es lo más simple, pero la recomendación del enunciado se pierde.
2. **Variable global con el modo actual.** Los widgets `const` no se redibujarían al cambiar el tema.
3. **Usar solo `ColorScheme` de Material.** No tiene huecos para el amarillo «de texto», la carcasa ni la sombra dura.
4. **Trivia siempre oscura (`TriviaDarkTheme`).** Fue la primera versión; se reemplazó porque las partes de abajo (récords, botones, ranking, logros) se veían oscuras dentro de una app en tema claro.

## Consecuencias

**A favor**
- Los dos temas cumplen el contraste mínimo y el cambio se aplica al instante.
- Un color nuevo se agrega en un solo lugar (`PixelColors`).

**En contra**
- Los escenarios de la trivia y el encabezado del detalle se ven oscuros también en el tema claro.
- Algunos adornos (barra de stats, sombra dura) tienen menos contraste en el tema claro, aunque nunca llevan información sin texto (RNF-ACC-05).

**Pruebas:** `pixel_colors_contrast_test.dart`, `pixel_colors_context_test.dart`, `theme_mode_cubit_test.dart` y `settings_page_test.dart`.

**Requisitos relacionados:** RF-COM-06, RNF-ACC-02, RNF-ACC-05.
