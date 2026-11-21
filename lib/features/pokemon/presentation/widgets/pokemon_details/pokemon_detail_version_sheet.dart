import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';
import 'package:pokedex/features/pokemon/domain/entities/move_version_group.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_badge.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_labels.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_section_title.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Hoja inferior para elegir la versión del juego (RF-DET-05).
/// Devuelve el id elegido, o null si se cierra sin elegir.
Future<int?> showPokemonVersionSheet(
  BuildContext context, {
  required List<MoveVersionGroup> groups,
  required int? selectedId,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: PixelPalette.panel,
    shape: const RoundedRectangleBorder(),
    builder: (context) => _VersionSheet(groups: groups, selectedId: selectedId),
  );
}

class _VersionSheet extends StatelessWidget {
  const _VersionSheet({required this.groups, required this.selectedId});

  final List<MoveVersionGroup> groups;
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
                child: PokemonDetailSectionTitle(l10n.movesVersionSheetTitle),
              ),
              IconButton(
                tooltip: l10n.detailFormClose,
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          // Hasta 32 versiones: la lista se desplaza.
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: groups.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final group = groups[index];
                return _VersionTile(
                  group: group,
                  isSelected: group.id == selectedId,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VersionTile extends StatelessWidget {
  const _VersionTile({required this.group, required this.isSelected});

  final MoveVersionGroup group;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return MergeSemantics(
      child: Material(
        color: isSelected ? PixelPalette.panelHigh : PixelPalette.panel,
        shape: Border.fromBorderSide(
          BorderSide(
            color: isSelected ? PixelPalette.accent : PixelPalette.panelBorder,
            width: 3,
          ),
        ),
        child: InkWell(
          onTap: () => Navigator.of(context).pop(group.id),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      prettifySlug(group.name),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontVariations: const [FontVariation('wght', 700)],
                      ),
                    ),
                  ),
                  // Reutiliza «Actual» / «Current» de las formas.
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
