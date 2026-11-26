import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex/app/router/app_routes.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_detail_cubit.dart';
import 'package:pokedex/features/pokemon/presentation/pages/pokemon_detail_page.dart';
import 'package:pokedex/core/connectivity/connectivity_monitor.dart';
import 'package:pokedex/core/connectivity/indicator/connectivity_indicator_cubit.dart';
import 'package:pokedex/core/di/service_locator.dart';
import 'package:pokedex/core/network/api_outage_simulator.dart';
import 'package:pokedex/core/sync/sync_info.dart';
import 'package:pokedex/features/favorites/presentation/favorites_page.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_repository.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_bloc.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_event.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/catalog_view_mode_cubit.dart';
import 'package:pokedex/features/pokemon/presentation/pages/catalog_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pokedex/features/trivia/domain/repositories/trivia_repository.dart';
import 'package:pokedex/features/trivia/presentation/cubit/trivia_achievements_cubit.dart';
import 'package:pokedex/features/trivia/presentation/cubit/trivia_game_cubit.dart';
import 'package:pokedex/features/trivia/presentation/cubit/trivia_home_cubit.dart';
import 'package:pokedex/features/trivia/presentation/cubit/trivia_ranking_cubit.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_play_page.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_screens.dart';
import 'package:pokedex/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:pokedex/features/onboarding/presentation/onboarding_page.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_detail_repository.dart';
import 'package:pokedex/features/pokemon/domain/repositories/type_chart_repository.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_moves_repository.dart';
import 'package:pokedex/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:pokedex/features/settings/presentation/cubit/manual_sync_cubit.dart';
import 'package:pokedex/features/settings/presentation/pages/settings_page.dart';
import 'package:pokedex/features/settings/presentation/widgets/outage_simulator_tile.dart';
import 'package:pokedex/features/settings/domain/repositories/saved_pokemon_repository.dart';
import 'package:pokedex/features/settings/presentation/cubit/saved_count_cubit.dart';
import 'package:pokedex/features/settings/presentation/widgets/walking_pokemon.dart';
import 'package:pokedex/features/favorites/presentation/cubit/favorites_list_cubit.dart';

import 'app_shell.dart';

/// Router de la aplicación. Cada pestaña es una rama con su propio estado.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.catalog,
  // La primera vez, cualquier ruta lleva antes a la introducción. Una vez
  // vista, se puede volver a abrir desde Ajustes.
  redirect: (context, state) {
    final seen = getIt<OnboardingRepository>().hasSeen;
    final onOnboarding = state.uri.path == AppRoutes.onboarding;
    if (!seen && !onOnboarding) {
      return AppRoutes.onboarding;
    }
    return null;
  },
  routes: [
    // Fuera del shell: la introducción no lleva barra de pestañas ni banda.
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => OnboardingPage(
        onFinished: () async {
          await getIt<OnboardingRepository>().markSeen();
          if (!context.mounted) {
            return;
          }
          // Desde Ajustes se vuelve a donde se estaba; la primera vez, al
          // catálogo.
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.catalog);
          }
        },
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<ConnectivityIndicatorCubit>(
              create: (context) => ConnectivityIndicatorCubit(
                monitor: getIt<ConnectivityMonitor>(),
                syncSource: getIt<SyncInfoSource>(),
              ),
            ),
            // Un solo cubit para la vista del catálogo: lo usan el catálogo
            // y Ajustes, así un cambio se ve en los dos.
            BlocProvider<CatalogViewModeCubit>(
              create: (context) =>
                  CatalogViewModeCubit(preferences: getIt<SharedPreferences>()),
            ),
          ],
          child: AppShell(
            navigationShell: navigationShell,
            // Pantallas abiertas encima de una pestaña: el detalle
            // (/catalog/:id) y la partida de trivia. Ahí la banda muestra volver.
            showBack:
                state.uri.path.startsWith('${AppRoutes.catalog}/') ||
                state.uri.path == AppRoutes.triviaPlay,
            // Durante la partida no se muestra la barra de pestañas: así nadie
            // cambia de pantalla por accidente a mitad del reloj.
            hideNavBar: state.uri.path == AppRoutes.triviaPlay,
          ),
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
                  ],
                  child: const CatalogPage(),
                );
              },
              routes: [
                // Detalle: /catalog/:id. Se abre encima del catálogo, dentro
                // del shell (el indicador de conectividad sigue visible).
                GoRoute(
                  path: AppRoutes.pokemonDetailSegment,
                  builder: (context, state) {
                    // Si el id no es un número, -1 no existe en la base y la
                    // pantalla muestra "Pokémon no encontrado".
                    final id =
                        int.tryParse(state.pathParameters['id'] ?? '') ?? -1;
                    return BlocProvider<PokemonDetailCubit>(
                      create: (context) => PokemonDetailCubit(
                        repository: getIt<PokemonRepository>(),
                        pokemonId: id,
                        detailRepository: getIt<PokemonDetailRepository>(),
                      ),
                      child: PokemonDetailPage(
                        typeChartRepository: getIt<TypeChartRepository>(),
                        detailRepository: getIt<PokemonDetailRepository>(),
                        movesRepository: getIt<PokemonMovesRepository>(),
                        favoritesRepository: getIt<FavoritesRepository>(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.favorites,
              builder: (context, state) => BlocProvider<FavoritesListCubit>(
                create: (context) => FavoritesListCubit(
                  repository: getIt<FavoritesRepository>(),
                ),
                child: const FavoritesPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.trivia,
              builder: (context, state) => BlocProvider<TriviaHomeCubit>(
                create: (_) =>
                    TriviaHomeCubit(repository: getIt<TriviaRepository>()),
                child: const TriviaHomeScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'play',
                  builder: (context, state) => BlocProvider<TriviaGameCubit>(
                    // start() arma las preguntas en cuanto se abre la partida.
                    create: (_) =>
                        TriviaGameCubit(repository: getIt<TriviaRepository>())
                          ..start(),
                    child: const TriviaPlayPage(),
                  ),
                ),
                GoRoute(
                  path: 'ranking',
                  builder: (context, state) => BlocProvider<TriviaRankingCubit>(
                    create: (_) => TriviaRankingCubit(
                      repository: getIt<TriviaRepository>(),
                    ),
                    child: const TriviaRankingScreen(),
                  ),
                ),
                GoRoute(
                  path: 'achievements',
                  builder: (context, state) =>
                      BlocProvider<TriviaAchievementsCubit>(
                        create: (_) => TriviaAchievementsCubit(
                          repository: getIt<TriviaRepository>(),
                        ),
                        child: const TriviaAchievementsScreen(),
                      ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => MultiBlocProvider(
                providers: [
                  BlocProvider<ManualSyncCubit>(
                    create: (context) =>
                        ManualSyncCubit(repository: getIt<PokemonRepository>()),
                  ),
                  BlocProvider<SavedCountCubit>(
                    create: (context) => SavedCountCubit(
                      repository: getIt<SavedPokemonRepository>(),
                    ),
                  ),
                ],
                child: SettingsPage(
                  testTools: getIt.isRegistered<ApiOutageSimulator>()
                      ? OutageSimulatorTile(
                          simulator: getIt<ApiOutageSimulator>(),
                          monitor: getIt<ConnectivityMonitor>(),
                        )
                      : null,
                  footer: WalkingPokemon(
                    repository: getIt<SavedPokemonRepository>(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
