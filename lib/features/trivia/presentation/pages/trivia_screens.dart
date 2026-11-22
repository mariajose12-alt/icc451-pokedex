import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex/app/router/app_routes.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_achievement.dart';
import 'package:pokedex/features/trivia/domain/entities/trivia_ranking_item.dart';
import 'package:pokedex/features/trivia/presentation/cubit/trivia_achievements_cubit.dart';
import 'package:pokedex/features/trivia/presentation/cubit/trivia_home_cubit.dart';
import 'package:pokedex/features/trivia/presentation/cubit/trivia_ranking_cubit.dart';
import 'package:pokedex/features/trivia/presentation/mappers/trivia_view_mapper.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_achievements_page.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_home_page.dart';
import 'package:pokedex/features/trivia/presentation/pages/trivia_ranking_page.dart';
import 'package:pokedex/l10n/app_localizations.dart';

class TriviaHomeScreen extends StatelessWidget {
  const TriviaHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TriviaHomeCubit, TriviaHomeState>(
      builder: (context, state) => TriviaHomePage(
        data: homeData(state),
        onPlay: () => context.go(AppRoutes.triviaPlay),
        onRanking: () => context.go(AppRoutes.triviaRanking),
        onAchievements: () => context.go(AppRoutes.triviaAchievements),
      ),
    );
  }
}

class TriviaRankingScreen extends StatelessWidget {
  const TriviaRankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TriviaRankingCubit, List<TriviaRankingItem>>(
      builder: (context, items) => TriviaRankingPage(
        entries: rankingEntries(items),
        onBack: () => context.go(AppRoutes.trivia),
      ),
    );
  }
}

class TriviaAchievementsScreen extends StatelessWidget {
  const TriviaAchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<
      TriviaAchievementsCubit,
      List<TriviaAchievementProgress>
    >(
      builder: (context, items) => TriviaAchievementsPage(
        achievements: achievementData(items, l10n),
        onBack: () => context.go(AppRoutes.trivia),
      ),
    );
  }
}
