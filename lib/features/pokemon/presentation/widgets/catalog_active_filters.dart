import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/features/pokemon/domain/entities/catalogo_query.dart';
import 'package:pokedex/features/pokemon/domain/repositories/type_chart_repository.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_bloc.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_event.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_state.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Muestra los filtros aplicados como chips que se pueden quitar, y avisa
/// que el filtro solo cubre los Pokémon guardados en el dispositivo.
class CatalogActiveFilters extends StatefulWidget {
  const CatalogActiveFilters({super.key});

  @override
  State<CatalogActiveFilters> createState() => _CatalogActiveFiltersState();
}

class _CatalogActiveFiltersState extends State<CatalogActiveFilters> {
  // Nombres de tipo leídos una sola vez, no en cada reconstrucción.
  Stream<Map<int, String>>? _nombresTipo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _nombresTipo ??= context.read<TypeChartRepository>().watchTypeNames();
  }

  /// Manda al Bloc el criterio con un cambio puntual.
  void _aplicar(
    BuildContext context,
    CatalogoQuery query, {
    Set<int>? tipos,
    Set<int>? generaciones,
    CatalogoOrden? orden,
  }) {
    context.read<CatalogBloc>().add(
      CatalogFilterChanged(
        tipoIds: tipos ?? query.tipoIds,
        generacionIds: generaciones ?? query.generacionIds,
        orden: orden ?? query.orden,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocBuilder<CatalogBloc, CatalogState>(
      builder: (context, state) {
        if (state is! CatalogSuccess || !state.query.hasActiveFilters) {
          return const SizedBox.shrink();
        }
        final query = state.query;

        return StreamBuilder<Map<int, String>>(
          stream: _nombresTipo,
          builder: (context, snapshot) {
            final nombres = snapshot.data ?? const <int, String>{};

            // Un chip por cada criterio activo. Al quitarlo, se manda el
            // criterio sin ese valor.
            final chips = <Widget>[
              for (final id in query.tipoIds)
                InputChip(
                  label: Text(nombres[id] ?? ''),
                  onDeleted: () => _aplicar(
                    context,
                    query,
                    tipos: {...query.tipoIds}..remove(id),
                  ),
                ),
              for (final id in query.generacionIds)
                InputChip(
                  label: Text('$id · ${_nombreRegion(l10n, id)}'),
                  onDeleted: () => _aplicar(
                    context,
                    query,
                    generaciones: {...query.generacionIds}..remove(id),
                  ),
                ),
              if (query.orden != CatalogoOrden.numero)
                InputChip(
                  label: Text(_nombreOrden(l10n, query.orden)),
                  onDeleted: () =>
                      _aplicar(context, query, orden: CatalogoOrden.numero),
                ),
            ];

            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ...chips,
                      TextButton(
                        onPressed: () => _aplicar(
                          context,
                          query,
                          tipos: <int>{},
                          generaciones: <int>{},
                          orden: CatalogoOrden.numero,
                        ),
                        child: Text(l10n.catalogClearAll),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.catalogPartialNotice,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

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

String _nombreOrden(AppLocalizations l10n, CatalogoOrden orden) {
  return switch (orden) {
    CatalogoOrden.numero => l10n.catalogSortNumber,
    CatalogoOrden.nombre => l10n.catalogSortName,
    CatalogoOrden.totalBase => l10n.catalogSortTotal,
  };
}
