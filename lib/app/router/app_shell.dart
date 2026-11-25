import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex/app/router/pokedex_nav_bar.dart';
import 'package:pokedex/core/connectivity/indicator/connectivity_indicator.dart';
import 'package:pokedex/l10n/app_localizations.dart';
import 'package:pokedex/core/widgets/pixel_sprite.dart';

/// Estructura común de las pantallas principales: indicador de conectividad
/// arriba (T-013) y barra de navegación abajo.
class AppShell extends StatelessWidget {
  const AppShell({
    required this.navigationShell,
    this.toolsMenu,
    this.showBack = false,
    this.hideNavBar = false,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  /// Herramientas de prueba (simulador de caída). null en producción.
  final Widget? toolsMenu;

  /// ¿Hay una pantalla abierta encima (el detalle)? Si es true, la barra de
  /// arriba muestra la flecha de volver.
  final bool showBack;

  /// ¿Se oculta la barra inferior? Es true en la partida de trivia.
  final bool hideNavBar;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Indicador global de conectividad (IND-01). En el detalle lleva
            // la flecha de volver en lugar de la lente.
            ConnectivityIndicator(
              trailing: toolsMenu,
              // Mismo camino que el botón atrás del sistema: el delegado de
              // go_router llama a maybePop, así que respeta el PopScope de
              // la partida de trivia (pide confirmación).
              onBack: showBack
                  ? () => GoRouter.of(context).routerDelegate.popRoute()
                  : null,
            ),
            Expanded(key: const ValueKey('shell-body'), child: navigationShell),
          ],
        ),
      ),
      bottomNavigationBar: hideNavBar
          ? null
          : PokedexNavBar(
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
                  sprite: PixelSprites.ball,
                  label: l10n.navPokedex,
                ),
                PokedexNavItem(
                  sprite: PixelSprites.heart,
                  label: l10n.navFavorites,
                ),
                PokedexNavItem(
                  sprite: PixelSprites.quiz,
                  label: l10n.navTrivia,
                ),
              ],
            ),
    );
  }
}
