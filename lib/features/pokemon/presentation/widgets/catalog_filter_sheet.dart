import 'package:flutter/material.dart';

/// Abre una hoja con chips. Con [multiple] en true se pueden elegir varios
/// valores; con false se elige uno y la hoja se cierra sola. Cada toque
/// aplica el cambio al instante a través de [onChanged].
Future<void> showCatalogFilterSheet(
  BuildContext context, {
  required String title,
  required Map<int, String> options,
  required Set<int> selected,
  required ValueChanged<Set<int>> onChanged,
  bool multiple = true,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _CatalogFilterSheet(
      title: title,
      options: options,
      selected: selected,
      onChanged: onChanged,
      multiple: multiple,
    ),
  );
}

class _CatalogFilterSheet extends StatefulWidget {
  const _CatalogFilterSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.multiple,
  });

  final String title;
  final Map<int, String> options;
  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;
  final bool multiple;

  @override
  State<_CatalogFilterSheet> createState() => _CatalogFilterSheetState();
}

class _CatalogFilterSheetState extends State<_CatalogFilterSheet> {
  // Copia local para que los chips respondan al instante.
  late Set<int> _seleccion = {...widget.selected};

  void _alternar(int id) {
    if (!widget.multiple) {
      // Selección única: se aplica y la hoja se cierra.
      widget.onChanged({id});
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      if (!_seleccion.add(id)) {
        _seleccion.remove(id);
      }
    });
    // Se avisa a la barra, que aplica el filtro al catálogo.
    widget.onChanged({..._seleccion});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ids = widget.options.keys.toList()..sort();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final id in ids)
                  FilterChip(
                    label: Text(
                      widget.options[id] ?? '',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: _seleccion.contains(id)
                            ? Colors.black
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    selected: _seleccion.contains(id),
                    showCheckmark: false,
                    selectedColor: theme.colorScheme.primary,
                    onSelected: (_) => _alternar(id),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
