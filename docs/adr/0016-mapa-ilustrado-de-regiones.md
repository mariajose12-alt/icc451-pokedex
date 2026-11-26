# ADR-0016: Mapa ilustrado de regiones en el detalle

- **Estado:** Aceptado
- **Fecha:** 2026-11-25
- **Requisitos:** RF-COM-07, RF-DET-10, OF-16/OF-17

## Contexto

RF-COM-07 pide un mapa ilustrado interactivo de las regiones o juegos en que
aparece cada Pokémon. Las regiones son ficticias: el PDF prohíbe usar mapas
geográficos convencionales sin justificación funcional.

## Decisión

- Una pestaña «Mapa» en el detalle dibuja un escenario hecho a mano con Flutter
  (`CustomPainter`): mar, nueve islas pixeladas de colores (una por generación),
  rutas, insignias ✓/✕ y brújula. No hay imágenes externas ni teselas.
- El mar tiene dos paletas (`RegionMapColors`): nocturna en tema oscuro y
  celeste con textos oscuros en tema claro, para no romper el tema claro.
- Las regiones son las nueve principales (Kanto a Paldea). Hisui (Leyendas:
  Arceus) cuenta como Sinnoh y Orre (Colosseum/XD) no se muestra.
- Al tocar una isla se listan, por entrega y con su nombre oficial, los juegos
  de esa región, además de la generación y los tres iniciales de la región.
- Los datos salen de `version_groups`, que ya se descarga con los movimientos
  del Pokémon. No hay consulta nueva ni migración: la UI sigue leyendo solo la
  base local (OF-16/OF-17) y funciona sin conexión.
- La correspondencia grupo de versión → región es una tabla constante en el
  dominio (`group_version_groups_by_region.dart`), con pruebas.

## Consecuencias

- Un Pokémon «aparece» en una región si tiene movimientos registrados en algún
  juego de ella. Es una aproximación con los datos disponibles; la pantalla lo
  indica. Datos más precisos (encuentros por área) pedirían otra consulta a
  PokeAPI y no se justifican para una función Recomendada.
- Un grupo de versión nuevo que no esté en la tabla no aparece hasta añadirlo.
- Alternativa descartada: un mapa geográfico real o imágenes de mapas (prohibido
  por el PDF y con peso/licencia innecesarios).
