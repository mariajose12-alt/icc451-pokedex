import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex/app/router/app_routes.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/pokemon_detail_cubit.dart';
import 'package:pokedex/features/pokemon/presentation/pages/pokemon_detail_page.dart';
import 'package:pokedex/app/router/tools_menu_button.dart';
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
import 'package:pokedex/features/trivia/presentation/pages/trivia_home_page.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_question_page.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_result_page.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_reveal_page.dart';
import 'package:pokedex/features/trivia/presentation/preview/trivia_sample_data.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_achievements_page.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_no_data_page.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_ranking_page.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_detail_repository.dart';
import 'package:pokedex/features/pokemon/domain/repositories/type_chart_repository.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_moves_repository.dart';
import 'package:pokedex/features/favorites/domain/repositories/favorites_repository.dart';

import 'app_shell.dart';

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
          child: AppShell(
            navigationShell: navigationShell,
            // El detalle vive en /catalog/:id; ahí la barra muestra volver.
            showBack: state.uri.path.startsWith('${AppRoutes.catalog}/'),
            toolsMenu: getIt.isRegistered<ApiOutageSimulator>()
                ? ToolsMenuButton(
                    simulator: getIt<ApiOutageSimulator>(),
                    monitor: getIt<ConnectivityMonitor>(),
                  )
                : null,
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
                    BlocProvider<CatalogViewModeCubit>(
                      create: (context) => CatalogViewModeCubit(
                        preferences: getIt<SharedPreferences>(),
                      ),
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
              builder: (context, state) => const FavoritesPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.trivia,
              builder: (context, state) => TriviaHomePage(
                data: TriviaSampleData.home,
                onPlay: () => context.go(AppRoutes.triviaQuestion),
                onRanking: () => context.go(AppRoutes.triviaRanking),
                onAchievements: () => context.go(AppRoutes.triviaAchievements),
              ),
              routes: [
                // TEMPORAL: la navegación entre pantallas es de ejemplo
                // (Adivinar → acierto, Saltar → tiempo agotado). El motor de
                // la trivia decidirá esto más adelante.
                GoRoute(
                  path: 'question',
                  builder: (context, state) => TriviaQuestionPage(
                    data: TriviaSampleData.question,
                    onGuess: () => context.go(AppRoutes.triviaCorrect),
                    onSkip: () => context.go(AppRoutes.triviaTimeUp),
                    onHint: () {}, // Sin lógica todavía.
                  ),
                ),
                GoRoute(
                  path: 'correct',
                  builder: (context, state) => TriviaRevealPage(
                    kind: TriviaRevealKind.correct,
                    data: TriviaSampleData.correct,
                    onNext: () => context.go(AppRoutes.triviaResult),
                  ),
                ),
                GoRoute(
                  path: 'time-up',
                  builder: (context, state) => TriviaRevealPage(
                    kind: TriviaRevealKind.timeUp,
                    data: TriviaSampleData.timeUp,
                    onNext: () => context.go(AppRoutes.triviaResult),
                  ),
                ),
                GoRoute(
                  path: 'result',
                  builder: (context, state) => TriviaResultPage(
                    data: TriviaSampleData.result,
                    onPlayAgain: () => context.go(AppRoutes.triviaQuestion),
                    onRanking: () => context.go(AppRoutes.triviaRanking),
                    onHome: () => context.go(AppRoutes.trivia),
                  ),
                ),
                GoRoute(
                  path: 'ranking',
                  builder: (context, state) => TriviaRankingPage(
                    entries: TriviaSampleData.ranking,
                    onBack: () => context.go(AppRoutes.trivia),
                  ),
                ),
                GoRoute(
                  path: 'achievements',
                  builder: (context, state) => TriviaAchievementsPage(
                    achievements: TriviaSampleData.achievements,
                    onBack: () => context.go(AppRoutes.trivia),
                  ),
                ),
                GoRoute(
                  path: 'no-data',
                  builder: (context, state) => TriviaNoDataPage(
                    data: TriviaSampleData.noData,
                    onGoCatalog: () => context.go(AppRoutes.catalog),
                    onRetry: () => context.go(AppRoutes.trivia),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
