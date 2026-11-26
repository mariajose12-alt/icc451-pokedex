import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_bloc.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_event.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_state.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/catalog_generation_sheet.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/catalog_search_field.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Barra compacta del catálogo: lupa para buscar y chips de filtros (RF-FIL-01).
class CatalogToolbar extends StatefulWidget {
  const CatalogToolbar({required this.initialText, this.trailing, super.key});

  /// Texto del último criterio de búsqueda guardado.
  final String initialText;

  /// Elemento a la derecha de los chips (p. ej. el selector Cuadrícula/Lista).
  final Widget? trailing;

  @override
  State<CatalogToolbar> createState() => _CatalogToolbarState();
}

class _CatalogToolbarState extends State<CatalogToolbar> {
  // Por defecto la barra de búsqueda está oculta; la lupa la muestra.
  bool _buscando = false;

  // Alto fijo para que todos los chips queden iguales.
  static const double _alturaChip = 28;

  /// Abre la hoja de generaciones y aplica lo elegido al Bloc.
  Future<void> _filtrarGeneracion(BuildContext context) async {
    final bloc = context.read<CatalogBloc>();
    final state = bloc.state;
    if (state is! CatalogSuccess) {
      return;
    }
    final query = state.query;

    final elegidas = await showGenerationFilterSheet(
      context,
      query.generacionIds,
    );
    // null = se cerró sin aplicar. Si la pantalla ya no existe, tampoco.
    if (elegidas == null || !context.mounted) {
      return;
    }

    // Se mandan los tres criterios juntos: tipos y orden no cambian aquí.
    bloc.add(
      CatalogFilterChanged(
        tipoIds: query.tipoIds,
        generacionIds: elegidas,
        orden: query.orden,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Chip con alto fijo. Si el texto no cabe, se corta con puntos suspensivos.
    Widget chip(String texto, {VoidCallback? onPressed}) {
      return SizedBox(
        height: _alturaChip,
        child: ActionChip(
          label: Text(
            texto,
            style: theme.textTheme.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          onPressed: onPressed ?? () {},
        ),
      );
    }

    return Padding(
      // 12 px a cada lado: el mismo margen que usa la cuadrícula de Pokémon.
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: _buscando
                    ? l10n.catalogSearchClose
                    : l10n.catalogSearchOpen,
                icon: Icon(_buscando ? Icons.close : Icons.search),
                onPressed: () => setState(() => _buscando = !_buscando),
              ),
              // Los tres chips comparten la fila y se reparten el espacio.
              Expanded(
                child: Row(
                  children: [
                    // Tipo: se conecta en el siguiente paso.
                    Expanded(child: chip(l10n.catalogFilterType)),
                    const SizedBox(width: 4),
                    // Generación: abre la hoja de regiones.
                    Expanded(
                      child: chip(
                        l10n.catalogFilterGeneration,
                        onPressed: () => _filtrarGeneracion(context),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Orden: se conecta más adelante.
                    Expanded(child: chip(l10n.catalogSortLabel)),
                  ],
                ),
              ),
              // Selector de vista a la derecha, si se pasa.
              if (widget.trailing != null) ...[
                const SizedBox(width: 8),
                widget.trailing!,
              ],
            ],
          ),
          // La barra de búsqueda aparece solo al pulsar la lupa.
          if (_buscando) CatalogSearchField(initialText: widget.initialText),
        ],
      ),
    );
  }
}
