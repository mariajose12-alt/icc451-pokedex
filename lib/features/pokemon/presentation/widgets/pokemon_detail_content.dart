import 'package:flutter/material.dart';
import 'package:pokedex/core/widgets/pixel_panel.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_detail_image.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_detail_metrics.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_type_backdrop.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/type_badge.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Contenido del detalle cuando el Pokémon está guardado: header con el color
/// de sus tipos, identidad (RF-DET-01) y medidas (RF-DET-07). Más adelante se
/// añadirán aquí stats, habilidades, etc.
class PokemonDetailContent extends StatelessWidget {
  const PokemonDetailContent({required this.pokemon, super.key});

  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Textos que se muestran (igual que en las tarjetas del catálogo).
    final number = '#${pokemon.nationalDexNumber.toString().padLeft(3, '0')}';
    final name = pokemon.name.isEmpty
        ? pokemon.name
        : pokemon.name[0].toUpperCase() + pokemon.name.substring(1);

    // Nombres de los tipos: sirven para el color del header y para la
    // etiqueta de lectores de pantalla.
    final typeNames = <String>[];
    for (final type in pokemon.types) {
      typeNames.add(type.name);
    }
    final spokenLabel = l10n.pokemonSemanticLabel(
      name,
      pokemon.nationalDexNumber,
      typeNames.join(', '),
    );

    // SingleChildScrollView: con texto grande no se desborda (RNF-ACC-04).
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PixelPanel(
        // Sin margen interior: el header de color llega hasta los bordes.
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: color de los tipos detrás y el artwork encima.
            SizedBox(
              height: 264,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PokemonTypeBackdrop(typeNames: typeNames),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    // El Hero envuelve la imagen: es lo que "vuela" desde el
                    // catálogo (RF-COM-02). El color de fondo se queda quieto.
                    child: Hero(
                      tag: PokemonDetailImage.heroTag(pokemon.id),
                      child: PokemonDetailImage(pokemon: pokemon),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Identidad: un solo bloque para el lector de pantalla.
                  Semantics(
                    container: true,
                    label: spokenLabel,
                    excludeSemantics: true,
                    child: Column(
                      children: [
                        Text(
                          number,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontVariations: const [FontVariation('wght', 700)],
                          ),
                        ),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontVariations: const [FontVariation('wght', 700)],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Uno o dos tipos; Wrap los acomoda si no caben.
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final type in pokemon.types)
                              TypeBadge(typeName: type.name),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Medidas (RF-DET-07): fuera del Semantics de arriba para
                  // que se lean como elementos propios.
                  PokemonDetailMetrics(
                    heightDecimeters: pokemon.height,
                    weightHectograms: pokemon.weight,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
