import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/connectivity/indicator/connectivity_indicator_cubit.dart';
import 'package:pokedex/core/connectivity/service_availability.dart';
import 'package:pokedex/core/sync/fake_sync_info_source.dart';
import 'package:pokedex/features/pokemon/data/repositories/fake_pokemon_repository.dart';
import 'package:pokedex/features/pokemon/presentation/cubit/catalog_view_mode_cubit.dart';
import 'package:pokedex/features/settings/presentation/cubit/locale_cubit.dart';
import 'package:pokedex/features/settings/presentation/cubit/theme_mode_cubit.dart';
import 'package:pokedex/features/settings/presentation/cubit/manual_sync_cubit.dart';
import 'package:pokedex/features/settings/presentation/cubit/saved_count_cubit.dart';
import 'package:pokedex/features/settings/presentation/pages/settings_page.dart';
import 'package:pokedex/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_connectivity_monitor.dart';
import '../../helpers/fake_saved_pokemon_repository.dart';

Future<({LocaleCubit locale, CatalogViewModeCubit view, ThemeModeCubit theme})>
_pump(
  WidgetTester tester, {
  required ServiceAvailability availability,
  double textScale = 1,
}) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final localeCubit = LocaleCubit(preferences: preferences);
  final viewCubit = CatalogViewModeCubit(preferences: preferences);
  final themeCubit = ThemeModeCubit(preferences: preferences);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<LocaleCubit>.value(value: localeCubit),
          BlocProvider<CatalogViewModeCubit>.value(value: viewCubit),
          BlocProvider<ThemeModeCubit>.value(value: themeCubit),
          BlocProvider<ConnectivityIndicatorCubit>(
            create: (_) => ConnectivityIndicatorCubit(
              monitor: FakeConnectivityMonitor(availability),
              syncSource: FakeSyncInfoSource(
                lastSyncAt: DateTime(2026, 11, 25, 10, 42),
              ),
            ),
          ),
          BlocProvider<ManualSyncCubit>(
            create: (_) => ManualSyncCubit(
              repository: FakePokemonRepository(
                scenario: FakeScenario.success,
                delay: Duration.zero,
              ),
            ),
          ),
          BlocProvider<SavedCountCubit>(
            create: (_) => SavedCountCubit(
              repository: FakeSavedPokemonRepository(count: 1025),
            ),
          ),
        ],
        child: const SettingsPage(),
      ),
    ),
  );
  await tester.pump();
  return (locale: localeCubit, view: viewCubit, theme: themeCubit);
}

void main() {
  testWidgets('la tarjeta muestra cuántos Pokémon hay y la última sync', (
    tester,
  ) async {
    await _pump(tester, availability: ServiceAvailability.online);

    expect(find.text('Tu Pokédex guarda'), findsOneWidget);
    expect(find.text('1025'), findsOneWidget);
    expect(find.textContaining('10:42'), findsOneWidget);
  });

  testWidgets('con conexión el botón de sincronizar está activo', (
    tester,
  ) async {
    await _pump(tester, availability: ServiceAvailability.online);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNotNull);
    expect(find.text('Necesitas conexión para sincronizar.'), findsNothing);
  });

  testWidgets('sin conexión el botón está desactivado y se explica por qué', (
    tester,
  ) async {
    await _pump(tester, availability: ServiceAvailability.offline);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
    expect(find.text('Necesitas conexión para sincronizar.'), findsOneWidget);
  });

  testWidgets('tocar Inglés cambia el idioma y Sistema lo devuelve', (
    tester,
  ) async {
    final cubits = await _pump(
      tester,
      availability: ServiceAvailability.online,
    );

    await tester.tap(find.text('Inglés'));
    await tester.pumpAndSettle();
    expect(cubits.locale.state, const Locale('en'));

    await tester.tap(find.text('Sistema').first);
    await tester.pumpAndSettle();
    expect(cubits.locale.state, isNull);
  });

  testWidgets('tocar Lista cambia la vista del catálogo', (tester) async {
    final cubits = await _pump(
      tester,
      availability: ServiceAvailability.online,
    );

    await tester.ensureVisible(find.text('Lista'));
    await tester.tap(find.text('Lista'));
    await tester.pumpAndSettle();

    expect(cubits.view.state, CatalogViewMode.list);
  });

  testWidgets('tocar Oscuro cambia el tema y Sistema lo devuelve', (
    tester,
  ) async {
    final cubits = await _pump(
      tester,
      availability: ServiceAvailability.online,
    );

    await tester.ensureVisible(find.text('Oscuro'));
    await tester.tap(find.text('Oscuro'));
    await tester.pumpAndSettle();
    expect(cubits.theme.state, ThemeMode.dark);

    // El «Sistema» del tema es el segundo (el primero es el del idioma).
    await tester.tap(find.text('Sistema').last);
    await tester.pumpAndSettle();
    expect(cubits.theme.state, ThemeMode.system);
  });

  testWidgets('con texto al 200 % no se desborda', (tester) async {
    await _pump(tester, availability: ServiceAvailability.online, textScale: 2);

    expect(tester.takeException(), isNull);
  });
}
