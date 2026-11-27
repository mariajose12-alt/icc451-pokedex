import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/core/theme/pixel_colors.dart';
import 'package:pokedex/features/pokemon/domain/entities/catalogo_query.dart';
import 'package:pokedex/features/pokemon/domain/repositories/type_chart_repository.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_bloc.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_state.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/catalog_view_mode_cubit.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/catalog_filter_sheet.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/catalog_search_field.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Barra del catálogo: búsqueda y un solo botón «Filtros» con el número de
/// criterios activos (RF-FIL-01). Tipo, generación, orden y la vista
/// (cuadrícula o lista) viven en la hoja inferior.
class CatalogToolbar extends StatelessWidget {
  const CatalogToolbar({
    required this.initialText,
    required this.onViewModeChanged,
    super.key,
  });

  /// Texto del último criterio de búsqueda guardado.
  final String initialText;

  /// Cambia la vista. La hace el listado, que conserva por dónde ibas.
  final ValueChanged<CatalogViewMode> onViewModeChanged;

  Future<void> _abrirHoja(BuildContext context, CatalogoQuery query) {
    return showCatalogFilterSheet(
      context,
      bloc: context.read<CatalogBloc>(),
      viewModeCubit: context.read<CatalogViewModeCubit>(),
      typeNames: context.read<TypeChartRepository>().watchTypeNames(),
      initial: query,
      onViewModeChanged: onViewModeChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogBloc, CatalogState>(
      builder: (context, state) {
        final query = state is CatalogSuccess
            ? state.query
            : const CatalogoQuery();

        // Mismos criterios que se ven como chips debajo: tipos, generaciones
        // y un orden distinto al normal.
        final activos =
            query.tipoIds.length +
            query.generacionIds.length +
            (query.orden != CatalogoOrden.numero ? 1 : 0);

        return Padding(
          // 12 px a cada lado: el mismo margen que usa la cuadrícula de Pokémon.
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: CatalogSearchField(
                  initialText: initialText,
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 10),
              _FilterButton(
                activeCount: activos,
                onPressed: () => unawaited(_abrirHoja(context, query)),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Botón cuadrado con embudo. Con criterios activos se pinta de amarillo y
/// muestra cuántos son.
class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.activeCount, required this.onPressed});

  final int activeCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.pixel;
    final active = activeCount > 0;

    return Semantics(
      button: true,
      label: active
          ? l10n.catalogFiltersActive(activeCount)
          : l10n.catalogFiltersButton,
      excludeSemantics: true,
      onTap: onPressed,
      child: Tooltip(
        message: l10n.catalogFiltersButton,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: colors.panelHigh,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: active ? colors.accentText : colors.panelBorder,
                  width: 3,
                ),
              ),
              child: InkWell(
                onTap: onPressed,
                // Objetivo táctil de 48 dp (RNF-ACC-03).
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(Icons.filter_alt, color: colors.text),
                ),
              ),
            ),
            if (active)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 22,
                    minHeight: 22,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.accent,
                    border: Border.all(color: colors.onAccent, width: 2),
                  ),
                  child: Text(
                    '$activeCount',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.onAccent,
                      fontVariations: const [FontVariation('wght', 700)],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
