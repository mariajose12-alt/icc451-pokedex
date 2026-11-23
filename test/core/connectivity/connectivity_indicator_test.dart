import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/connectivity/indicator/connectivity_indicator.dart';
import 'package:pokedex/core/connectivity/indicator/connectivity_indicator_cubit.dart';
import 'package:pokedex/core/connectivity/service_availability.dart';
import 'package:pokedex/core/sync/fake_sync_info_source.dart';
import 'package:pokedex/core/sync/sync_info.dart';
import 'package:pokedex/l10n/app_localizations.dart';

import '../../helpers/fake_connectivity_monitor.dart';

void main() {
  late FakeConnectivityMonitor monitor;
  late FakeSyncInfoSource sync;
  late ConnectivityIndicatorCubit cubit;

  setUp(() {
    monitor = FakeConnectivityMonitor();
    sync = FakeSyncInfoSource();
    // Ventana corta para que la prueba no tarde.
    cubit = ConnectivityIndicatorCubit(
      monitor: monitor,
      syncSource: sync,
      stabilityWindow: const Duration(milliseconds: 50),
    );
  });

  tearDown(() async {
    await cubit.close();
    await monitor.dispose();
  });

  test('la primera respuesta se muestra de inmediato', () async {
    monitor.emit(ServiceAvailability.online);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.availability, ServiceAvailability.online);
  });

  test('un cambio solo se muestra después de la ventana', () async {
    monitor.emit(ServiceAvailability.online);
    await Future<void>.delayed(Duration.zero);

    monitor.emit(ServiceAvailability.offline);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.availability, ServiceAvailability.online);

    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(cubit.state.availability, ServiceAvailability.offline);
  });

  test('una caída breve no se muestra (IND-06)', () async {
    monitor.emit(ServiceAvailability.online);
    await Future<void>.delayed(Duration.zero);

    final seen = <ServiceAvailability>[];
    final subscription = cubit.stream.listen((s) => seen.add(s.availability));

    monitor.emit(ServiceAvailability.offline);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    monitor.emit(ServiceAvailability.online);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await subscription.cancel();

    expect(seen, isNot(contains(ServiceAvailability.offline)));
    expect(cubit.state.availability, ServiceAvailability.online);
  });

  test('la sincronización y la última hora llegan de inmediato', () async {
    sync.emit(
      SyncInfo(isSyncing: true, lastSyncAt: DateTime(2026, 10, 26, 10, 42)),
    );
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.isSyncing, isTrue);
    expect(cubit.state.lastSyncAt, DateTime(2026, 10, 26, 10, 42));
  });

  testWidgets('Offline muestra icono, texto y etiqueta Semantics (IND-05)', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final offlineMonitor = FakeConnectivityMonitor(ServiceAvailability.offline);
    final offlineCubit = ConnectivityIndicatorCubit(
      monitor: offlineMonitor,
      syncSource: FakeSyncInfoSource(),
    );
    addTearDown(offlineCubit.close);
    addTearDown(offlineMonitor.dispose);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BlocProvider<ConnectivityIndicatorCubit>.value(
            value: offlineCubit,
            child: const ConnectivityIndicator(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sin conexión'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Estado de conexión: Sin conexión')),
      findsOneWidget,
    );
    handle.dispose();
  });
}
