import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/pixel_colors.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_form.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_badge.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_labels.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_section_title.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_type_names.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_image.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/type_badge.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Abre la hoja inferior para elegir la forma (RF-DET-08).
/// Devuelve el id de la forma elegida, o null si se cierra sin elegir.
Future<int?> showPokemonFormSheet(
  BuildContext context, {
  required String pokemonName,
  required List<PokemonForm> forms,
  required int? selectedId,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.pixel.panel,
    // Esquinas rectas, como el resto de la interfaz pixelada.
    shape: const RoundedRectangleBorder(),
    builder: (context) => _FormSheet(
      pokemonName: pokemonName,
      forms: forms,
      selectedId: selectedId,
    ),
  );
}

class _FormSheet extends StatelessWidget {
  const _FormSheet({
    required this.pokemonName,
    required this.forms,
    required this.selectedId,
  });

  final String pokemonName;
  final List<PokemonForm> forms;
  final int? selectedId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: PokemonDetailSectionTitle(l10n.detailFormSheetTitle),
              ),
              IconButton(
                tooltip: l10n.detailFormClose,
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          // Lista con scroll: algunas especies tienen muchas formas.
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: forms.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final form = forms[index];
                return _FormTile(
                  label: formLabel(l10n, pokemonName, form),
                  form: form,
                  isSelected: form.id == selectedId,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FormTile extends StatelessWidget {
  const _FormTile({
    required this.label,
    required this.form,
    required this.isSelected,
  });

  final String label;
  final PokemonForm form;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // MergeSemantics: «Mega X, fire, dragon» se lee como un solo botón.
    return MergeSemantics(
      child: Material(
        color: isSelected ? context.pixel.panelHigh : context.pixel.panel,
        shape: Border.fromBorderSide(
          BorderSide(
            color: isSelected
                ? context.pixel.accent
                : context.pixel.panelBorder,
            width: 3,
          ),
        ),
        child: InkWell(
          onTap: () => Navigator.of(context).pop(form.id),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: PokemonImage(
                      url: form.spriteUrl,
                      iconSize: 24,
                      memCacheWidth: 160,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontVariations: const [FontVariation('wght', 700)],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            for (final name in formTypeNames(form))
                              TypeBadge(typeName: name),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isSelected) PokemonDetailBadge(l10n.detailFormCurrent),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
