import 'package:pokedex/features/pokemon/domain/entities/pokemon_form.dart';

/// Resuelve qué forma se está viendo y qué imagen corresponde, a partir de la
/// forma elegida y de si se pidió shiny. No usa widgets: se prueba solo.
class PokemonFormSelection {
  const PokemonFormSelection._({
    required this.current,
    required this.isOtherForm,
    required this.canShiny,
    required this.shinyOn,
    required this.overrideImage,
    required this.artworkUrl,
    required this.spriteUrl,
  });

  factory PokemonFormSelection.resolve({
    required List<PokemonForm> forms,
    required int? chosenFormId,
    required bool shinyRequested,
  }) {
    PokemonForm? defaultForm;
    PokemonForm? chosen;
    for (final form in forms) {
      if (form.isDefault && defaultForm == null) {
        defaultForm = form;
      }
      if (form.id == chosenFormId) {
        chosen = form;
      }
    }
    // Si ninguna viene marcada como normal, se usa la primera.
    defaultForm ??= forms.isEmpty ? null : forms.first;

    // Un id que ya no existe cae en la forma normal.
    final current = chosen ?? defaultForm;
    final isOtherForm = chosen != null && !chosen.isDefault;
    final canShiny = current != null && current.hasShiny;
    final shinyOn = shinyRequested && canShiny;

    // Solo se cambian las imágenes si hay otra forma o shiny. La forma
    // normal usa las del catálogo (así el Hero no se rompe).
    var overrideImage = false;
    String? artworkUrl;
    String? spriteUrl;
    if (current != null && (isOtherForm || shinyOn)) {
      overrideImage = true;
      artworkUrl = shinyOn ? current.shinyArtworkUrl : current.artworkUrl;
      spriteUrl = shinyOn ? current.shinySpriteUrl : current.spriteUrl;
    }

    return PokemonFormSelection._(
      current: current,
      isOtherForm: isOtherForm,
      canShiny: canShiny,
      shinyOn: shinyOn,
      overrideImage: overrideImage,
      artworkUrl: artworkUrl,
      spriteUrl: spriteUrl,
    );
  }

  /// Forma que se ve: la elegida o, si no, la normal. Null si no hay formas.
  final PokemonForm? current;

  /// ¿Se eligió una forma distinta de la normal?
  final bool isOtherForm;

  /// ¿La forma actual tiene imagen shiny?
  final bool canShiny;

  /// ¿Se está mostrando la versión shiny?
  final bool shinyOn;

  /// Si es true, la imagen grande usa [artworkUrl] y [spriteUrl] en lugar de
  /// las del Pokémon del catálogo.
  final bool overrideImage;
  final String? artworkUrl;
  final String? spriteUrl;
}
