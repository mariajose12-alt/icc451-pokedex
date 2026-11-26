import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/features/pokemon/domain/entities/catalogo_query.dart';
import 'package:pokedex/features/pokemon/domain/repositories/type_chart_repository.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_bloc.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_event.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_state.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/catalog_filter_sheet.dart';
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

  /// Aplica un cambio de filtro. Lo que no cambia se toma del estado actual.
  void _aplicar(
    BuildContext context, {
    Set<int>? tipos,
    Set<int>? generaciones,
    CatalogoOrden? orden,
  }) {
    final bloc = context.read<CatalogBloc>();
    final state = bloc.state;
    if (state is! CatalogSuccess) {
      return;
    }
    final query = state.query;
    bloc.add(
      CatalogFilterChanged(
        tipoIds: tipos ?? query.tipoIds,
        generacionIds: generaciones ?? query.generacionIds,
        orden: orden ?? query.orden,
      ),
    );
  }

  /// Abre la hoja de tipos. Los nombres se leen de la base al abrirla.
  Future<void> _abrirTipos(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final nombres = await context
        .read<TypeChartRepository>()
        .watchTypeNames()
        .first;
    if (!context.mounted) {
      return;
    }
    final state = context.read<CatalogBloc>().state;
    final seleccion = state is CatalogSuccess ? state.query.tipoIds : <int>{};

    await showCatalogFilterSheet(
      context,
      title: l10n.catalogFilterType,
      options: nombres,
      selected: seleccion,
      onChanged: (nuevos) => _aplicar(context, tipos: nuevos),
    );
  }

  /// Abre la hoja de generaciones: número y nombre de la región, por ejemplo
  /// "1 · Kanto".
  Future<void> _abrirGeneraciones(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final state = context.read<CatalogBloc>().state;
    final seleccion = state is CatalogSuccess
        ? state.query.generacionIds
        : <int>{};

    final opciones = {
      for (var n = 1; n <= 9; n++) n: '$n · ${_nombreRegion(l10n, n)}',
    };

    await showCatalogFilterSheet(
      context,
      title: l10n.catalogFilterGeneration,
      options: opciones,
      selected: seleccion,
      onChanged: (nuevas) => _aplicar(context, generaciones: nuevas),
    );
  }

  /// Abre la hoja de orden. Es de selección única: al elegir, se cierra.
  /// Los ids son la posición en [CatalogoOrden]: 0 número, 1 nombre, 2 total.
  Future<void> _abrirOrden(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final state = context.read<CatalogBloc>().state;
    final actual = state is CatalogSuccess
        ? state.query.orden
        : CatalogoOrden.numero;

    await showCatalogFilterSheet(
      context,
      title: l10n.catalogSortLabel,
      options: {
        0: l10n.catalogSortNumber,
        1: l10n.catalogSortName,
        2: l10n.catalogSortTotal,
      },
      selected: {actual.index},
      multiple: false,
      onChanged: (nuevo) =>
          _aplicar(context, orden: CatalogoOrden.values[nuevo.first]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocBuilder<CatalogBloc, CatalogState>(
      builder: (context, state) {
        final query = state is CatalogSuccess
            ? state.query
            : const CatalogoQuery();

        // Chip de la fila principal. Si tiene algo distinto a lo normal, se pinta.
        Widget chip(
          String texto, {
          required VoidCallback onPressed,
          bool activo = false,
        }) {
          return SizedBox(
            height: _alturaChip,
            child: ActionChip(
              label: Text(
                texto,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: activo ? Colors.black : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              backgroundColor: activo ? theme.colorScheme.primary : null,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              onPressed: onPressed,
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
                        Expanded(
                          child: chip(
                            l10n.catalogFilterType,
                            activo: query.tipoIds.isNotEmpty,
                            onPressed: () => _abrirTipos(context),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: chip(
                            l10n.catalogFilterGeneration,
                            activo: query.generacionIds.isNotEmpty,
                            onPressed: () => _abrirGeneraciones(context),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: chip(
                            l10n.catalogSortLabel,
                            activo: query.orden != CatalogoOrden.numero,
                            onPressed: () => _abrirOrden(context),
                          ),
                        ),
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
              if (_buscando)
                CatalogSearchField(initialText: widget.initialText),
            ],
          ),
        );
      },
    );
  }
}

/// Nombre de la región de cada generación (RF-FIL-01).
String _nombreRegion(AppLocalizations l10n, int generacion) {
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
