import 'package:flutter/material.dart';
import 'package:pokedex/app/theme/type_colors.dart';

/// Etiqueta con el color de un tipo de Pokémon. Texto e color a la vez:
/// el tipo nunca se comunica solo con color (RNF-ACC-05).
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: color.foreground, fontWeight: FontWeight.w600),
      ),
    );
  }
}
