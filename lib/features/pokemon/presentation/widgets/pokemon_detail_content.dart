import 'package:flutter/material.dart';
import 'package:pokedex/core/widgets/pixel_panel.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_detail_image.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/type_badge.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Contenido del detalle cuando el Pokémon está guardado: identidad completa
/// (RF-DET-01). Más adelante se añadirán aquí stats, habilidades, etc.
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

    // Etiqueta para lectores de pantalla: nombre, número y tipos de una vez.
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
        padding: const EdgeInsets.all(16),
        child: Semantics(
          container: true,
          label: spokenLabel,
          excludeSemantics: true,
          child: Column(
            children: [
              // El Hero envuelve la imagen: es lo que "vuela" desde el
              // catálogo (RF-COM-02).
              Hero(
                tag: PokemonDetailImage.heroTag(pokemon.id),
                child: SizedBox(
                  height: 240,
                  width: double.infinity,
                  child: PokemonDetailImage(pokemon: pokemon),
                ),
              ),
              const SizedBox(height: 12),
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
              // Uno o dos tipos; Wrap los acomoda si no caben en una línea.
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
      ),
    );
  }
}