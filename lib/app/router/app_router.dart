import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex/core/connectivity/connectivity_monitor.dart';
import 'package:pokedex/core/connectivity/indicator/connectivity_indicator_cubit.dart';
import 'package:pokedex/core/di/service_locator.dart';
import 'package:pokedex/core/sync/sync_info.dart';
import 'package:pokedex/features/favorites/presentation/favorites_page.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_bloc.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_event.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/catalog_view_mode_cubit.dart';
import 'package:pokedex/features/pokemon/presentation/pages/catalog_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_shell.dart';

/// Rutas de las pestañas principales.
abstract final class AppRoutes {
  static const String catalog = '/catalog';
  static const String favorites = '/favorites';
}

/// Router de la aplicación. Cada pestaña es una rama con su propio estado.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.catalog,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return BlocProvider<ConnectivityIndicatorCubit>(
          create: (context) => ConnectivityIndicatorCubit(
            monitor: getIt<ConnectivityMonitor>(),
            syncSource: getIt<SyncInfoSource>(),
          ),
          child: AppShell(navigationShell: navigationShell),
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.catalog,
              builder: (context, state) {
                return MultiBlocProvider(
                  providers: [
                    BlocProvider<CatalogBloc>(
                      create: (context) =>
                          CatalogBloc(repository: getIt<PokemonRepository>())
                            ..add(const CatalogStarted()),
                    ),
                    BlocProvider<CatalogViewModeCubit>(
                      create: (context) => CatalogViewModeCubit(
                        preferences: getIt<SharedPreferences>(),
                      ),
                    ),
                  ],
                  child: const CatalogPage(),
                );
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.favorites,
              builder: (context, state) => const FavoritesPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
