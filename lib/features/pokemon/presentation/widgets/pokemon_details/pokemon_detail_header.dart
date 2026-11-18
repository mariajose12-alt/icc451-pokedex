import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_extras.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_form.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_extras_cubit.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_action_button.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_form_sheet.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_image.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_labels.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_form_selection.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_type_names.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_type_backdrop.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/type_badge.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Cabecera del detalle (RF-DET-01): franja con los colores de los tipos,
/// imagen en un marco que sobresale, número, nombre y tipos. Incluye los
/// botones de shiny (RF-DET-09) y de formas (RF-DET-08).
class PokemonDetailHeader extends StatefulWidget {
  const PokemonDetailHeader({
    required this.pokemon,
    this.hasExtras = false,
    super.key,
  });

  final Pokemon pokemon;

  /// ¿Hay un [PokemonExtrasCubit] arriba? Si es false, shiny y formas quedan
  /// desactivados.
  final bool hasExtras;

  @override
  State<PokemonDetailHeader> createState() => _PokemonDetailHeaderState();
}

class _PokemonDetailHeaderState extends State<PokemonDetailHeader> {
  // Alto de la franja de color y tamaño del marco de la imagen.
  static const double _bandHeight = 92;
  static const double _artworkSize = 128;

  // Estado de pantalla: no se guarda ni lo necesita otra pantalla.
  bool _shiny = false;
  int? _formId;

  @override
  Widget build(BuildContext context) {
    if (!widget.hasExtras) {
      return _buildHeader(context, PokemonExtras.empty);
    }
    return BlocBuilder<PokemonExtrasCubit, PokemonExtras>(
      builder: (context, extras) => _buildHeader(context, extras),
    );
  }

  Future<void> _openFormSheet(PokemonFormSelection selection) async {
    final picked = await showPokemonFormSheet(
      context,
      pokemonName: widget.pokemon.name,
      forms: _forms,
      selectedId: selection.current?.id,
    );
    if (picked != null && mounted) {
      setState(() => _formId = picked);
    }
  }

  // Formas de la última construcción; las usa la hoja al abrirse.
  List<PokemonForm> _forms = const <PokemonForm>[];

  Widget _buildHeader(BuildContext context, PokemonExtras extras) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final pokemon = widget.pokemon;

    _forms = extras.forms;
    final selection = PokemonFormSelection.resolve(
      forms: extras.forms,
      chosenFormId: _formId,
      shinyRequested: _shiny,
    );

    // Textos que se muestran (igual que en las tarjetas del catálogo).
    final number = '#${pokemon.nationalDexNumber.toString().padLeft(3, '0')}';
    final name = pokemon.name.isEmpty
        ? pokemon.name
        : pokemon.name[0].toUpperCase() + pokemon.name.substring(1);

    // Con otra forma elegida, la cabecera muestra los tipos de esa forma.
    final current = selection.current;
    final typeNames = <String>[];
    String? formText;
    if (selection.isOtherForm && current != null) {
      typeNames.addAll(formTypeNames(current));
      formText = formLabel(l10n, pokemon.name, current);
    }
    if (typeNames.isEmpty) {
      for (final type in pokemon.types) {
        typeNames.add(type.name);
      }
    }

    var spokenLabel = l10n.pokemonSemanticLabel(
      name,
      pokemon.nationalDexNumber,
      typeNames.join(', '),
    );
    if (formText != null) {
      spokenLabel = '$spokenLabel, $formText';
    }

    return Stack(
      children: [
        // La franja de color queda arriba, de borde a borde.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: _bandHeight,
          child: PokemonTypeBackdrop(typeNames: typeNames),
        ),
        // Imagen e identidad. El margen superior de 36 hace que el marco
        // empiece dentro de la franja y sobresalga por debajo.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 36, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ArtworkFrame(
                pokemon: pokemon,
                size: _artworkSize,
                shiny: selection.shinyOn,
                overrideImage: selection.overrideImage,
                artworkUrl: selection.artworkUrl,
                spriteUrl: selection.spriteUrl,
              ),
              const SizedBox(width: 16),
              Expanded(
                // 68 = lo que falta para que la identidad empiece justo debajo
                // de la franja (36 + 68 = 104, y la franja mide 92).
                child: Padding(
                  padding: const EdgeInsets.only(top: 68),
                  // Un solo bloque para el lector de pantalla.
                  child: Semantics(
                    container: true,
                    label: spokenLabel,
                    excludeSemantics: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: number,
                            children: [
                              if (formText != null)
                                TextSpan(
                                  text: ' · $formText',
                                  style: const TextStyle(
                                    color: PixelPalette.accent,
                                  ),
                                ),
                            ],
                          ),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontVariations: const [FontVariation('wght', 700)],
                          ),
                        ),
                        Text(
                          name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontSize: 30,
                            height: 1.05,
                            fontVariations: const [FontVariation('wght', 700)],
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Uno o dos tipos; Wrap los baja de línea si no caben.
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final typeName in typeNames)
                              TypeBadge(typeName: typeName),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Acciones rápidas sobre la franja. Compartir se conecta en B9.
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PokemonDetailActionButton(
                icon: Icons.auto_awesome,
                label: l10n.detailActionShiny,
                iconColor: PixelPalette.accent,
                selected: selection.shinyOn,
                // Solo si la forma actual tiene imagen shiny.
                onPressed: selection.canShiny
                    ? () => setState(() => _shiny = !_shiny)
                    : null,
              ),
              PokemonDetailActionButton(
                icon: Icons.layers,
                label: l10n.detailActionForm,
                showDot: selection.isOtherForm,
                // Solo si la especie tiene más de una forma.
                onPressed: extras.forms.length > 1
                    ? () => _openFormSheet(selection)
                    : null,
              ),
              PokemonDetailActionButton(
                icon: Icons.share,
                label: l10n.detailActionShare,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Marco pixelado de la imagen: borde oscuro, sombra dura y un filete interior.
/// Con shiny activo, el borde exterior se vuelve amarillo.
class _ArtworkFrame extends StatelessWidget {
  const _ArtworkFrame({
    required this.pokemon,
    required this.size,
    required this.shiny,
    required this.overrideImage,
    required this.artworkUrl,
    required this.spriteUrl,
  });

  final Pokemon pokemon;
  final double size;
  final bool shiny;
  final bool overrideImage;
  final String? artworkUrl;
  final String? spriteUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: PixelPalette.panel,
          border: Border.fromBorderSide(
            BorderSide(
              color: shiny ? PixelPalette.accent : PixelPalette.background,
              width: 3,
            ),
          ),
          boxShadow: const [
            BoxShadow(color: PixelPalette.shadow, offset: Offset(4, 4)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              border: Border.fromBorderSide(
                BorderSide(color: PixelPalette.panelBorder, width: 2),
              ),
            ),
            // El Hero envuelve la imagen: es lo que "vuela" desde el
            // catálogo (RF-COM-02). El marco se queda quieto.
            child: Hero(
              tag: PokemonDetailImage.heroTag(pokemon.id),
              child: PokemonDetailImage(
                pokemon: pokemon,
                overrideImage: overrideImage,
                artworkUrl: artworkUrl,
                spriteUrl: spriteUrl,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
