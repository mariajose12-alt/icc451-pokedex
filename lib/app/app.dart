import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/core/theme/app_theme.dart';
import 'package:pokedex/features/settings/presentation/cubit/locale_cubit.dart';
import 'package:pokedex/features/settings/presentation/cubit/theme_mode_cubit.dart';
import 'package:pokedex/l10n/app_localizations.dart';

import 'router/app_router.dart';

/// Raíz visual de la aplicación.
class PokedexApp extends StatelessWidget {
  const PokedexApp({
    required this.localeCubit,
    required this.themeModeCubit,
    super.key,
  });

  final LocaleCubit localeCubit;
  final ThemeModeCubit themeModeCubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>.value(value: localeCubit),
        BlocProvider<ThemeModeCubit>.value(value: themeModeCubit),
      ],
      child: BlocBuilder<LocaleCubit, Locale?>(
        builder: (context, locale) {
          return BlocBuilder<ThemeModeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp.router(
                onGenerateTitle: (context) =>
                    AppLocalizations.of(context)!.appTitle,
                // Claro y oscuro (RF-COM-06); `themeMode` elige cuál se usa.
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: themeMode,
                routerConfig: appRouter,
                locale: locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
              );
            },
          );
        },
      ),
    );
  }
}
