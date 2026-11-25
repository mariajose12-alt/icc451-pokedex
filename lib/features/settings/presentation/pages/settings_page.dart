import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pokedex/core/connectivity/indicator/connectivity_indicator_cubit.dart';
import 'package:pokedex/core/connectivity/indicator/connectivity_indicator_state.dart';
import 'package:pokedex/core/connectivity/service_availability.dart';
import 'package:pokedex/core/errors/failures.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';
import 'package:pokedex/core/widgets/pixel_panel.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/catalog_view_mode_cubit.dart';
import 'package:pokedex/features/settings/presentation/cubit/locale_cubit.dart';
import 'package:pokedex/features/settings/presentation/cubit/manual_sync_cubit.dart';
import 'package:pokedex/features/settings/presentation/cubit/saved_count_cubit.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Ajustes: lo guardado y la sincronización arriba, preferencias debajo.
/// Todo se guarda en el dispositivo (RF-FIL-04).
class SettingsPage extends StatelessWidget {
  const SettingsPage({this.testTools, this.footer, super.key});

  /// Herramientas solo para pruebas (simulador de caída, PA-08). Es null
  /// cuando el simulador no está habilitado.
  final Widget? testTools;

  /// Adorno fijo al pie, encima de la barra de navegación.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<ManualSyncCubit, ManualSyncState>(
      // Solo avisa cuando la sincronización falla.
      listenWhen: (_, current) => current is ManualSyncFailed,
      listener: (context, state) {
        final failure = (state as ManualSyncFailed).failure;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(_failureMessage(l10n, failure))),
          );
      },
      child: Scaffold(
        body: Column(
          children: [
            // Con el texto grande la lista se desplaza; el pie queda fijo.
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.settingsTitle,
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.settingsSubtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: PixelPalette.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Lo guardado, la última sincronización y sincronizar (PS-04).
                  const _SavedCard(),
                  const SizedBox(height: 20),

                  // Idioma (RF-COM-05, RF-TRV-06): un toque, sin diálogo.
                  BlocBuilder<LocaleCubit, Locale?>(
                    builder: (context, locale) {
                      final code =
                          const {'es', 'en'}.contains(locale?.languageCode)
                          ? locale!.languageCode
                          : 'system';
                      return _Choice<String>(
                        label: l10n.languageTitle,
                        selected: code,
                        options: [
                          ('system', l10n.languageSystem, null),
                          ('es', l10n.languageSpanish, null),
                          ('en', l10n.languageEnglish, null),
                        ],
                        onChanged: (value) => unawaited(
                          context.read<LocaleCubit>().select(
                            value == 'system' ? null : Locale(value),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Vista del catálogo (RF-FIL-04).
                  BlocBuilder<CatalogViewModeCubit, CatalogViewMode>(
                    builder: (context, mode) => _Choice<CatalogViewMode>(
                      label: l10n.settingsCatalogView,
                      selected: mode,
                      options: [
                        (CatalogViewMode.grid, l10n.viewGrid, Icons.grid_view),
                        (CatalogViewMode.list, l10n.viewList, Icons.view_list),
                      ],
                      onChanged: (value) => unawaited(
                        context.read<CatalogViewModeCubit>().select(value),
                      ),
                    ),
                  ),

                  // Herramientas de prueba: solo si el simulador está habilitado.
                  if (testTools != null) ...[
                    const SizedBox(height: 28),
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.settingsTestTools,
                        style: textTheme.titleMedium?.copyWith(
                          color: PixelPalette.textMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    testTools!,
                  ],
                ],
              ),
            ),
            ?footer,
          ],
        ),
      ),
    );
  }
}

String _failureMessage(AppLocalizations l10n, Failure failure) {
  return switch (failure) {
    NoConnectionFailure() => l10n.errorNoConnection,
    TimeoutFailure() => l10n.errorTimeout,
    RateLimitFailure() => l10n.errorRateLimit,
    ServiceFailure() => l10n.errorService,
    UnknownFailure() => l10n.errorUnknown,
  };
}

/// Tarjeta superior: cuántos Pokémon hay guardados, cuándo se sincronizó
/// por última vez (IND-04) y el botón de sincronización manual (PS-04).
class _SavedCard extends StatelessWidget {
  const _SavedCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final localeName = Localizations.localeOf(context).toString();
    final count = context.select((SavedCountCubit cubit) => cubit.state);

    return PixelPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Un solo bloque para el lector: "Tu Pokédex guarda 1025 Pokémon…".
          MergeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsSavedLabel,
                  style: textTheme.bodyMedium?.copyWith(
                    color: PixelPalette.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                // Con el texto al 200 % la unidad baja a otra línea.
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 8,
                  children: [
                    Text(
                      '$count',
                      style: textTheme.headlineLarge?.copyWith(
                        color: PixelPalette.accent,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      l10n.settingsSavedUnit,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                BlocBuilder<
                  ConnectivityIndicatorCubit,
                  ConnectivityIndicatorState
                >(
                  builder: (context, indicator) {
                    final lastSyncAt = indicator.lastSyncAt;
                    final time = lastSyncAt == null
                        ? l10n.indicatorNeverSynced
                        : DateFormat.yMd(localeName)
                              .add_Hm()
                              .format(lastSyncAt.toLocal());
                    return Text(
                      l10n.settingsLastSyncValue(time),
                      style: textTheme.bodySmall?.copyWith(
                        color: PixelPalette.textMuted,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _SyncButton(),
        ],
      ),
    );
  }
}

/// Botón «Sincronizar ahora». Solo se activa con el servicio disponible y
/// sin otra sincronización en curso; si no, un texto explica por qué.
class _SyncButton extends StatelessWidget {
  const _SyncButton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<ConnectivityIndicatorCubit, ConnectivityIndicatorState>(
      builder: (context, indicator) {
        return BlocBuilder<ManualSyncCubit, ManualSyncState>(
          builder: (context, manual) {
            final running = manual is ManualSyncRunning || indicator.isSyncing;
            final online = indicator.availability == ServiceAvailability.online;
            final canSync = online && !running;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: canSync
                      ? () => unawaited(context.read<ManualSyncCubit>().sync())
                      : null,
                  child: Text(
                    running ? l10n.indicatorSyncing : l10n.settingsSyncNow,
                  ),
                ),
                if (!online && !running)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      l10n.settingsSyncNeedsConnection,
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: PixelPalette.textMuted,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Título y selector de opciones siempre visibles (elección única).
class _Choice<T> extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final T selected;

  /// Cada opción: valor, texto e icono opcional.
  final List<(T, String, IconData?)> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.titleSmall?.copyWith(
            color: PixelPalette.textMuted,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        SegmentedButton<T>(
          showSelectedIcon: false,
          // Ocupa todo el ancho y cada opción mide al menos 48 dp (RNF-ACC-03).
          expandedInsets: EdgeInsets.zero,
          style: const ButtonStyle(
            minimumSize: WidgetStatePropertyAll(Size(48, 48)),
          ),
          segments: [
            for (final option in options)
              ButtonSegment<T>(
                value: option.$1,
                icon: option.$3 == null ? null : Icon(option.$3),
                label: Text(option.$2),
              ),
          ],
          selected: {selected},
          onSelectionChanged: (selection) => onChanged(selection.first),
        ),
      ],
    );
  }
}
