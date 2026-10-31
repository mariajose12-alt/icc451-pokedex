import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pokedex/core/connectivity/connectivity_monitor.dart';
import 'package:pokedex/core/network/api_outage_simulator.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Lo que se puede elegir en el menú.
enum _ToolsAction { simulateOutage }

/// Menú de tres puntos de la banda superior. Por ahora solo trae el
/// simulador de caída de la API (PA-08); luego tendrá la configuración.
class ToolsMenuButton extends StatelessWidget {
  const ToolsMenuButton({
    required this.simulator,
    required this.monitor,
    super.key,
  });

  final ApiOutageSimulator simulator;
  final ConnectivityMonitor monitor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<_ToolsAction>(
      icon: const Icon(Icons.more_vert, color: PixelPalette.text),
      tooltip: MaterialLocalizations.of(context).showMenuTooltip,
      onSelected: (action) {
        switch (action) {
          case _ToolsAction.simulateOutage:
            simulator.value = !simulator.value;
            // Sin esto el indicador tardaría hasta 5 min en enterarse:
            // se fuerza una comprobación del servicio ahora mismo.
            unawaited(monitor.checkNow());
        }
      },
      // Se construye al abrir el menú, así la marca refleja el valor actual.
      itemBuilder: (context) => [
        CheckedPopupMenuItem<_ToolsAction>(
          value: _ToolsAction.simulateOutage,
          checked: simulator.value,
          child: Text(l10n.debugSimulateOutage),
        ),
      ],
    );
  }
}
