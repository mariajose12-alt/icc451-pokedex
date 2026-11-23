import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex/app/router/pokedex_nav_bar.dart';
import 'package:pokedex/core/connectivity/indicator/connectivity_indicator.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Estructura común de las pantallas principales: indicador de conectividad
/// arriba (T-013) y barra de navegación abajo.
class AppShell extends StatelessWidget {
  const AppShell({
    required this.navigationShell,
    this.toolsMenu,
    this.showBack = false,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  /// Herramientas de prueba (simulador de caída). null en producción.
  final Widget? toolsMenu;

  /// ¿Hay una pantalla abierta encima (el detalle)? Si es true, la barra de
  /// arriba muestra la flecha de volver.
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Lo que va al final de la barra de arriba: herramientas y, si hay una
    // pantalla encima, la flecha de volver.
    final menu = toolsMenu;
    final Widget? trailing = (menu == null && !showBack)
        ? null
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ?menu,
              if (showBack)
                IconButton(
                  tooltip: l10n.detailBack,
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
            ],
          );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Indicador global de conectividad (IND-01).
            ConnectivityIndicator(trailing: trailing),
            Expanded(key: const ValueKey('shell-body'), child: navigationShell),
          ],
        ),
      ),
      bottomNavigationBar: PokedexNavBar(
        selectedIndex: navigationShell.currentIndex,
        onSelected: (index) {
          // Tocar la pestaña activa vuelve a su pantalla inicial.
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        items: [
          PokedexNavItem(
            icon: Icons.catching_pokemon_outlined,
            selectedIcon: Icons.catching_pokemon,
            label: l10n.navPokedex,
          ),
          /*
          PokedexNavItem(
            icon: Icons.favorite_border,
            selectedIcon: Icons.favorite,
            label: l10n.navFavorites,
          ),
          */
        ],
      ),
    );
  }
}
