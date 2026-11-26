import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pokedex/core/connectivity/connectivity_monitor.dart';
import 'package:pokedex/core/network/api_outage_simulator.dart';
import 'package:pokedex/core/widgets/pixel_panel.dart';
import 'package:pokedex/l10n/app_localizations.dart';
import 'package:pokedex/core/theme/pixel_colors.dart';

/// Interruptor para simular la caída de la API con la red activa (PA-08).
/// Solo se muestra cuando el simulador está habilitado (debug, o release con
/// --dart-define=API_SIMULATOR=true).
class OutageSimulatorTile extends StatelessWidget {
  const OutageSimulatorTile({
    required this.simulator,
    required this.monitor,
    super.key,
  });

  final ApiOutageSimulator simulator;
  final ConnectivityMonitor monitor;

  void _toggle() {
    simulator.value = !simulator.value;
    // Sin esto el indicador tardaría hasta 5 min en enterarse:
    // se fuerza una comprobación del servicio ahora mismo.
    unawaited(monitor.checkNow());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colors = context.pixel;

    // El simulador es un ValueNotifier: el interruptor se redibuja solo.
    return ValueListenableBuilder<bool>(
      valueListenable: simulator,
      builder: (context, isDown, _) {
        // Un solo bloque para el lector de pantalla: texto + interruptor.
        return MergeSemantics(
          child: PixelPanel(
            onTap: _toggle,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.debugSimulateOutage,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.settingsOutageHint,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(value: isDown, onChanged: (_) => _toggle()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
