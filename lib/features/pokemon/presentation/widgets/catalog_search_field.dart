import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/core/theme/pixel_colors.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_bloc.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_event.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Barra de búsqueda por nombre (RF-CAT-03).
/// Solo envía el texto al Bloc: el debounce vive en el Bloc.
class CatalogSearchField extends StatefulWidget {
  const CatalogSearchField({
    required this.initialText,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 8),
    super.key,
  });

  /// Texto con el que empieza la barra (el último criterio guardado).
  final String initialText;

  /// Espacio alrededor de la barra.
  final EdgeInsetsGeometry padding;

  @override
  State<CatalogSearchField> createState() => _CatalogSearchFieldState();
}

class _CatalogSearchFieldState extends State<CatalogSearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialText,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _enviar(String texto) {
    context.read<CatalogBloc>().add(CatalogSearchChanged(texto));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.pixel;

    // Borde grueso y recto, como el resto de la interfaz pixelada.
    OutlineInputBorder borde(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: color, width: 3),
    );

    return Padding(
      padding: widget.padding,
      child: TextField(
        controller: _controller,
        onChanged: _enviar,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: l10n.catalogSearchHint,
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: colors.background,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: borde(colors.panelBorder),
          enabledBorder: borde(colors.panelBorder),
          focusedBorder: borde(colors.accentText),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                tooltip: l10n.catalogSearchClear,
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  // clear() no dispara onChanged, así que lo enviamos a mano.
                  _enviar('');
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
