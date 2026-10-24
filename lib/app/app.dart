import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/core/theme/app_theme.dart';
import 'package:pokedex/features/settings/presentation/cubit/locale_cubit.dart';
import 'package:pokedex/l10n/app_localizations.dart';

import 'router/app_router.dart';

/// Raíz visual de la aplicación.
class PokedexApp extends StatelessWidget {
  const PokedexApp({required this.localeCubit, super.key});

  final LocaleCubit localeCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LocaleCubit>.value(
      value: localeCubit,
      child: BlocBuilder<LocaleCubit, Locale?>(
        builder: (context, locale) {
          return MaterialApp.router(
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)!.appTitle,
            theme: AppTheme.dark,
            routerConfig: appRouter,
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );
  }
}
