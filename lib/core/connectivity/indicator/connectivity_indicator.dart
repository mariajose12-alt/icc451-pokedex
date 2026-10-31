import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';
import 'package:pokedex/l10n/app_localizations.dart';

import '../service_availability.dart';
import 'connectivity_indicator_cubit.dart';
import 'connectivity_indicator_state.dart';
import 'pokedex_lights.dart';

/// Indicador global de conectividad (PF §7), con forma de lente y luces
/// de Pokédex. Va fijo arriba en el AppShell.
class ConnectivityIndicator extends StatelessWidget {
  const ConnectivityIndicator({this.trailing, super.key});

  /// Widget opcional al final de la banda (por ejemplo, el menú de tres
  /// puntos). Va fuera del texto que leen los lectores de pantalla, para
  /// seguir siendo un botón independiente.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final localeName = Localizations.localeOf(context).toString();

    return BlocBuilder<ConnectivityIndicatorCubit, ConnectivityIndicatorState>(
      builder: (context, state) {
        // Paso 1: texto de la última sincronización (IND-04).
        final String syncText;
        final lastSyncAt = state.lastSyncAt;
        if (lastSyncAt == null) {
          syncText = l10n.indicatorNeverSynced;
        } else {
          final hour = DateFormat.Hm(localeName).format(lastSyncAt.toLocal());
          syncText = l10n.indicatorLastSync(hour);
        }

        // Paso 2: «Sincronizando» solo se muestra si el servicio está Online.
        final isSyncing =
            state.isSyncing && state.availability == ServiceAvailability.online;

        // Paso 3: icono del lente, luz encendida, título y detalle.
        final IconData icon;
        final IndicatorLed lit;
        final String title;
        final String detail;

        if (isSyncing) {
          icon = Icons.sync;
          lit = IndicatorLed.green;
          title = l10n.indicatorSyncing;
          detail = l10n.indicatorDetailSyncing;
        } else {
          switch (state.availability) {
            case ServiceAvailability.checking:
              icon = Icons.hourglass_top;
              lit = IndicatorLed.none;
              title = l10n.indicatorChecking;
              detail = l10n.indicatorDetailChecking;
            case ServiceAvailability.online:
              icon = Icons.cloud_done;
              lit = IndicatorLed.green;
              title = l10n.indicatorOnline;
              detail = l10n.indicatorDetailOnline(syncText);
            case ServiceAvailability.offline:
              icon = Icons.cloud_off;
              lit = IndicatorLed.red;
              title = l10n.indicatorOffline;
              detail = l10n.indicatorDetailOffline(syncText);
            case ServiceAvailability.serviceUnavailable:
              icon = Icons.warning_amber_rounded;
              lit = IndicatorLed.yellow;
              title = l10n.indicatorUnavailable;
              detail = l10n.indicatorDetailUnavailable(syncText);
          }
        }

        // Paso 4: dibujar. El lector de pantalla lee una sola frase (IND-05)
        // y avisa cuando cambia (liveRegion).
        return Semantics(
          container: true,
          liveRegion: true,
          label: l10n.indicatorSemantics(title, detail),
          child: ExcludeSemantics(
            child: Material(
              // Rojo de la carcasa de la Pokédex.
              color: PixelPalette.shell,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: PixelPalette.shellDark, width: 4),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      // Lente: su icono dice el estado; late al sincronizar.
                      PokedexLens(icon: icon, pulsing: isSyncing),
                      const SizedBox(width: 14),
                      // Con el texto al 200 % esta columna se parte en líneas
                      // y no se pierde contenido (RNF-ACC-04).
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                PokedexLeds(lit: lit),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    title,
                                    style: textTheme.titleSmall?.copyWith(
                                      color: PixelPalette.text,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              detail,
                              style: textTheme.bodySmall?.copyWith(
                                color: PixelPalette.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ); // Paso 4: dibujar. El lector de pantalla lee una sola frase (IND-05)
        // y avisa cuando cambia (liveRegion). El menú del final queda fuera
        // de esa frase: es un botón aparte.
        return Material(
          // Rojo de la carcasa de la Pokédex.
          color: PixelPalette.shell,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: PixelPalette.shellDark, width: 4),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      container: true,
                      liveRegion: true,
                      label: l10n.indicatorSemantics(title, detail),
                      child: ExcludeSemantics(
                        child: Row(
                          children: [
                            // Lente: su icono dice el estado; late al sincronizar.
                            PokedexLens(icon: icon, pulsing: isSyncing),
                            const SizedBox(width: 14),
                            // Con el texto al 200 % esta columna se parte en
                            // líneas y no se pierde contenido (RNF-ACC-04).
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      PokedexLeds(lit: lit),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: textTheme.titleSmall?.copyWith(
                                            color: PixelPalette.text,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    detail,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: PixelPalette.text,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
