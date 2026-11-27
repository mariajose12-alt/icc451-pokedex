import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/core/theme/pixel_colors.dart';
import 'package:pokedex/core/theme/type_colors.dart';
import 'package:pokedex/features/pokemon/domain/entities/catalogo_query.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_bloc.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_event.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_state.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/catalog_view_mode_cubit.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Tipos especiales de PokeAPI que ningún Pokémon del catálogo usa como tipo
/// normal: no se ofrecen como filtro.
const Set<String> _tiposOcultos = {'unknown', 'shadow', 'stellar'};

/// Abre la hoja inferior de filtros y vista: forma de ver el catálogo (cuadrícula
/// o lista), orden, tipos y generaciones. Todo se aplica al tocar; el botón de
/// abajo solo cierra la hoja y dice cuántos resultados hay.
///
/// Recibe el Bloc y el Cubit ya leídos: la hoja vive en la ruta del Navigator,
/// que puede no ver los Providers de la pantalla.
Future<void> showCatalogFilterSheet(
  BuildContext context, {
  required CatalogBloc bloc,
  required CatalogViewModeCubit viewModeCubit,
  required Stream<Map<int, String>> typeNames,
  required CatalogoQuery initial,
  required ValueChanged<CatalogViewMode> onViewModeChanged,
}) {
  final colors = context.pixel;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: colors.panel,
    // Esquinas rectas: el borde grueso lo dibuja la propia hoja.
    shape: const RoundedRectangleBorder(),
    // Nunca ocupa toda la pantalla: se ve el catálogo detrás.
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.85,
    ),
    builder: (_) => _CatalogFilterSheet(
      bloc: bloc,
      viewModeCubit: viewModeCubit,
      typeNames: typeNames,
      initial: initial,
      onViewModeChanged: onViewModeChanged,
    ),
  );
}

class _CatalogFilterSheet extends StatefulWidget {
  const _CatalogFilterSheet({
    required this.bloc,
    required this.viewModeCubit,
    required this.typeNames,
    required this.initial,
    required this.onViewModeChanged,
  });

  final CatalogBloc bloc;
  final CatalogViewModeCubit viewModeCubit;
  final Stream<Map<int, String>> typeNames;
  final CatalogoQuery initial;
  final ValueChanged<CatalogViewMode> onViewModeChanged;

  @override
  State<_CatalogFilterSheet> createState() => _CatalogFilterSheetState();
}

class _CatalogFilterSheetState extends State<_CatalogFilterSheet> {
  // Copia local de lo elegido: los chips responden al instante y cada toque
  // manda el criterio completo, sin depender de que el Bloc ya lo devolviera.
  late final Set<int> _tipos = {...widget.initial.tipoIds};
  late final Set<int> _generaciones = {...widget.initial.generacionIds};
  late CatalogoOrden _orden = widget.initial.orden;

  bool get _hayFiltros =>
      _tipos.isNotEmpty ||
      _generaciones.isNotEmpty ||
      _orden != CatalogoOrden.numero;

  void _enviar() {
    widget.bloc.add(
      CatalogFilterChanged(
        tipoIds: {..._tipos},
        generacionIds: {..._generaciones},
        orden: _orden,
      ),
    );
  }

  void _alternar(Set<int> conjunto, int id) {
    setState(() {
      if (!conjunto.add(id)) {
        conjunto.remove(id);
      }
    });
    _enviar();
  }

  void _elegirOrden(CatalogoOrden orden) {
    setState(() => _orden = orden);
    _enviar();
  }

  void _limpiar() {
    setState(() {
      _tipos.clear();
      _generaciones.clear();
      _orden = CatalogoOrden.numero;
    });
    _enviar();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.pixel;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.panelBorder, width: 4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHeader(title: l10n.catalogFiltersTitle),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(l10n.catalogViewLabel, first: true),
                  BlocBuilder<CatalogViewModeCubit, CatalogViewMode>(
                    bloc: widget.viewModeCubit,
                    builder: (context, mode) =>
                        _PixelSegmented<CatalogViewMode>(
                          selected: mode,
                          onSelected: widget.onViewModeChanged,
                          options: [
                            _Option(
                              CatalogViewMode.grid,
                              l10n.viewGrid,
                              Icons.grid_view,
                            ),
                            _Option(
                              CatalogViewMode.list,
                              l10n.viewList,
                              Icons.view_list,
                            ),
                          ],
                        ),
                  ),
                  _SectionLabel(l10n.catalogSortLabel),
                  _PixelSegmented<CatalogoOrden>(
                    selected: _orden,
                    onSelected: _elegirOrden,
                    options: [
                      _Option(CatalogoOrden.numero, l10n.catalogSortNumber),
                      _Option(CatalogoOrden.nombre, l10n.catalogSortName),
                      _Option(CatalogoOrden.totalBase, l10n.catalogSortTotal),
                    ],
                  ),
                  _SectionLabel(l10n.catalogFilterType),
                  StreamBuilder<Map<int, String>>(
                    stream: widget.typeNames,
                    builder: (context, snapshot) {
                      final nombres = snapshot.data ?? const <int, String>{};
                      final ids =
                          nombres.keys
                              .where(
                                (id) => !_tiposOcultos.contains(nombres[id]),
                              )
                              .toList()
                            ..sort();

                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final id in ids)
                            _tipoChip(nombres[id] ?? '', id),
                        ],
                      );
                    },
                  ),
                  _SectionLabel(l10n.catalogFilterGeneration),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var n = 1; n <= 9; n++)
                        _PixelChip(
                          label: '$n · ${_nombreRegion(l10n, n)}',
                          selected: _generaciones.contains(n),
                          fill: colors.accent,
                          onFill: colors.onAccent,
                          onTap: () => _alternar(_generaciones, n),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.panel,
              border: Border(
                top: BorderSide(color: colors.panelBorder, width: 3),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                child: Row(
                  children: [
                    _SheetButton(
                      label: l10n.catalogClearFilter,
                      onPressed: _hayFiltros ? _limpiar : null,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: BlocBuilder<CatalogBloc, CatalogState>(
                        bloc: widget.bloc,
                        builder: (context, state) {
                          final total = state is CatalogSuccess
                              ? state.pokemon.length
                              : 0;
                          return _SheetButton(
                            primary: true,
                            label: l10n.catalogShowResults(total),
                            onPressed: () => Navigator.of(context).pop(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Chip de un tipo: color del tipo al elegirlo, y siempre texto.
  Widget _tipoChip(String nombre, int id) {
    final color =
        PokemonTypeColors.byName[nombre] ?? PokemonTypeColors.fallback;
    final etiqueta = nombre.isEmpty
        ? nombre
        : nombre[0].toUpperCase() + nombre.substring(1);

    return _PixelChip(
      label: etiqueta,
      selected: _tipos.contains(id),
      fill: color.background,
      onFill: color.foreground,
      // Cuadrito de color mientras no está elegido.
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color.background,
          border: Border.all(color: context.pixel.background, width: 2),
        ),
      ),
      onTap: () => _alternar(_tipos, id),
    );
  }
}

/// Asa para arrastrar, título y botón de cerrar.
class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.pixel;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(width: 40, height: 6, color: colors.panelBorder),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 4, 0),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colors.text,
                      fontVariations: const [FontVariation('wght', 700)],
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                icon: Icon(Icons.close, color: colors.text),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {this.first = false});

  final String text;
  final bool first;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: first ? 4 : 20, bottom: 8),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: context.pixel.textMuted,
            fontVariations: const [FontVariation('wght', 700)],
          ),
        ),
      ),
    );
  }
}

/// Una opción de un selector: valor, texto y, si quiere, un icono.
class _Option<T> {
  const _Option(this.value, this.label, [this.icon]);

  final T value;
  final String label;
  final IconData? icon;
}

/// Selector de una sola opción con las casillas pegadas. La elegida va en
/// amarillo y con una palomita: el estado no depende solo del color.
class _PixelSegmented<T> extends StatelessWidget {
  const _PixelSegmented({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<_Option<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.pixel;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colors.panelBorder, width: 3),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < options.length; i++)
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: i == 0
                        ? null
                        : Border(
                            left: BorderSide(
                              color: colors.panelBorder,
                              width: 3,
                            ),
                          ),
                  ),
                  child: _Segment(
                    label: options[i].label,
                    icon: options[i].icon,
                    isSelected: options[i].value == selected,
                    onTap: () => onSelected(options[i].value),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.pixel;
    final color = isSelected ? colors.onAccent : colors.text;
    final leading = isSelected ? Icons.check : icon;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: isSelected ? colors.accent : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            // Objetivo táctil de 48 dp (RNF-ACC-03).
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leading != null) ...[
                    Icon(leading, size: 18, color: color),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: color,
                        fontVariations: const [FontVariation('wght', 700)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Chip pixelado de selección múltiple. Elegido: relleno de [fill], borde del
/// color del texto y palomita.
class _PixelChip extends StatelessWidget {
  const _PixelChip({
    required this.label,
    required this.selected,
    required this.fill,
    required this.onFill,
    required this.onTap,
    this.leading,
  });

  final String label;
  final bool selected;
  final Color fill;
  final Color onFill;
  final VoidCallback onTap;

  /// Se ve mientras el chip no está elegido.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final colors = context.pixel;
    final color = selected ? onFill : colors.text;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: selected ? fill : colors.panelHigh,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: selected ? colors.text : colors.panelBorder,
            width: 3,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    Icon(Icons.check, size: 16, color: color),
                    const SizedBox(width: 6),
                  ] else if (leading != null) ...[
                    leading!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: color,
                      fontVariations: const [FontVariation('wght', 700)],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón del pie de la hoja. Sin [onPressed] se ve apagado.
class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.onPressed,
    this.primary = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final colors = context.pixel;
    final enabled = onPressed != null;
    final textColor = primary ? colors.onAccent : colors.text;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Semantics(
        button: true,
        enabled: enabled,
        child: Padding(
          // Espacio para la sombra dura, igual que PixelPanel.
          padding: const EdgeInsets.only(right: 4, bottom: 4),
          child: DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: primary
                  ? [
                      BoxShadow(
                        color: colors.shadow,
                        offset: const Offset(4, 4),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: primary ? colors.accent : colors.panelHigh,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: primary ? colors.onAccent : colors.panelBorder,
                  width: 3,
                ),
              ),
              child: InkWell(
                onTap: onPressed,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: textColor,
                          fontVariations: const [FontVariation('wght', 700)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
