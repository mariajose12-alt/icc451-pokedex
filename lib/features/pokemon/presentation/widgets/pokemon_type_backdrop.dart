import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/pixel_colors.dart';
import 'package:pokedex/core/theme/type_colors.dart';

/// Fondo de color del header del detalle.
///  - Un tipo: todo el fondo con el color de ese tipo.
///  - Dos tipos: dos mitades de bloque duro, una por tipo (estilo pixelado,
///    sin degradados).
/// Es solo decoración: el tipo se comunica también con texto e icono en las
/// etiquetas (RNF-ACC-05), por eso no tiene semántica propia.
class PokemonTypeBackdrop extends StatelessWidget {
  const PokemonTypeBackdrop({required this.typeNames, super.key});

  /// Nombres de los tipos tal como los da PokeAPI, p. ej. ['grass', 'poison'].
  final List<String> typeNames;

  @override
  Widget build(BuildContext context) {
    // Un color por tipo; si el tipo no está en la tabla, el color de respaldo.
    final colors = <Color>[];
    for (final name in typeNames) {
      final typeColor =
          PokemonTypeColors.byName[name] ?? PokemonTypeColors.fallback;
      colors.add(typeColor.background);
    }
    // Sin tipos guardados: un solo bloque de respaldo.
    if (colors.isEmpty) {
      colors.add(PokemonTypeColors.fallback.background);
    }

    final pixel = context.pixel;

    return ExcludeSemantics(
      child: DecoratedBox(
        // Línea oscura debajo, para separar el header del resto del panel.
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: pixel.panelBorder, width: 3),
          ),
        ),
        child: Row(
          // stretch: cada bloque ocupa todo el alto del header.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final color in colors)
              Expanded(child: ColoredBox(color: color)),
          ],
        ),
      ),
    );
  }
}
