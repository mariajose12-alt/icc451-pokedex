import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex/core/connectivity/indicator/connectivity_indicator.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Estructura común de las pantallas principales: indicador de conectividad
/// arriba (T-013) y barra de navegación abajo.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Indicador global de conectividad (IND-01).
            const ConnectivityIndicator(),
            Expanded(child: navigationShell),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          // Tocar la pestaña activa vuelve a su pantalla inicial.
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.catching_pokemon_outlined),
            selectedIcon: Icon(Icons.catching_pokemon),
            label: l10n.navPokedex,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
            label: l10n.navFavorites,
          ),
        ],
      ),
    );
  }
}
