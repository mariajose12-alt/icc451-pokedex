import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/type_colors.dart';

/// Etiqueta pixelada de un tipo de Pokémon: color, icono y texto a la vez
/// (el tipo nunca se comunica solo con color, RNF-ACC-05).
class TypeBadge extends StatelessWidget {
  const TypeBadge({required this.typeName, super.key});

  /// Nombre del tipo tal como lo devuelve PokeAPI, p. ej. "grass".
  final String typeName;

  @override
  Widget build(BuildContext context) {
    final color =
        PokemonTypeColors.byName[typeName] ?? PokemonTypeColors.fallback;
    final label = typeName.isEmpty
        ? typeName
        : typeName[0].toUpperCase() + typeName.substring(1);

    // Bisel: borde claro arriba y a la izquierda, oscuro abajo y a la derecha.
    final light = Color.lerp(color.background, Colors.white, 0.35)!;
    final dark = Color.lerp(color.background, Colors.black, 0.35)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.background,
        border: Border(
          top: BorderSide(color: light, width: 2),
          left: BorderSide(color: light, width: 2),
          bottom: BorderSide(color: dark, width: 2),
          right: BorderSide(color: dark, width: 2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(color.icon, size: 14, color: color.foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color.foreground,
              fontVariations: const [FontVariation('wght', 700)],
            ),
          ),
        ],
      ),
    );
  }
}
