import 'package:flutter/material.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Abre la hoja de generaciones. Devuelve las elegidas, o null si se cierra
/// sin aplicar.
Future<Set<int>?> showGenerationFilterSheet(
  BuildContext context,
  Set<int> seleccionadas,
) {
  return showModalBottomSheet<Set<int>>(
    context: context,
    // Permite que la hoja use más altura y se pueda desplazar.
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _GenerationFilterSheet(seleccionadas: seleccionadas),
  );
}

/// Nombre de la región de cada generación (RF-FIL-01).
String _regionName(AppLocalizations l10n, int generacion) {
  return switch (generacion) {
    1 => l10n.catalogRegion1,
    2 => l10n.catalogRegion2,
    3 => l10n.catalogRegion3,
    4 => l10n.catalogRegion4,
    5 => l10n.catalogRegion5,
    6 => l10n.catalogRegion6,
    7 => l10n.catalogRegion7,
    8 => l10n.catalogRegion8,
    _ => l10n.catalogRegion9,
  };
}

class _GenerationFilterSheet extends StatefulWidget {
  const _GenerationFilterSheet({required this.seleccionadas});

  final Set<int> seleccionadas;

  @override
  State<_GenerationFilterSheet> createState() => _GenerationFilterSheetState();
}

class _GenerationFilterSheetState extends State<_GenerationFilterSheet> {
  // Copia de trabajo: nada cambia en el catálogo hasta pulsar «Aplicar».
  late final Set<int> _seleccion = {...widget.seleccionadas};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SafeArea(
      // Si la pantalla es chica, todo el contenido se desplaza.
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                l10n.catalogGenerationSheetTitle,
                style: theme.textTheme.titleMedium,
              ),
            ),
            for (final generacion in List.generate(9, (i) => i + 1))
              CheckboxListTile(
                value: _seleccion.contains(generacion),
                title: Text('$generacion · ${_regionName(l10n, generacion)}'),
                onChanged: (marcada) {
                  setState(() {
                    if (marcada == true) {
                      _seleccion.add(generacion);
                    } else {
                      _seleccion.remove(generacion);
                    }
                  });
                },
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, <int>{}),
                      child: Text(l10n.catalogClearFilter),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, _seleccion),
                      child: Text(l10n.catalogApplyFilter),
                    ),
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
