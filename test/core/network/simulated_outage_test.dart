import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/app/router/tools_menu_button.dart' show ToolsMenuButton;
import 'package:pokedex/core/network/api_outage_simulator.dart';
import 'package:pokedex/core/network/network_exceptions.dart';
import 'package:pokedex/core/network/simulated_outage_poke_api_client.dart';
import 'package:pokedex/l10n/app_localizations.dart';

import '../../helpers/fake_connectivity_monitor.dart';

void main() {
  test('con la caída activa lanza error 503 sin tocar la red', () async {
    final simulator = ApiOutageSimulator()..value = true;
    final client = SimulatedOutagePokeApiClient(
      url: 'http://invalido.test',
      timeout: const Duration(seconds: 1),
      simulator: simulator,
    );

    await expectLater(
      client.query('query { x }'),
      throwsA(
        isA<ServerErrorException>().having(
          (error) => error.statusCode,
          'statusCode',
          503,
        ),
      ),
    );
  });

  testWidgets('el interruptor activa y desactiva la caída simulada', (
    tester,
  ) async {
    final simulator = ApiOutageSimulator();
    final monitor = FakeConnectivityMonitor();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: OutageSimulatorTile(simulator: simulator, monitor: monitor),
        ),
      ),
    );

    // Tocar el interruptor activa la caída.
    await tester.tap(find.byType(Switch));
    // Abrir el menú y elegir la opción.
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    final opcion = find.text('Simular caída de la API (solo pruebas)');
    await tester.ensureVisible(opcion);
    await tester.pumpAndSettle();
    await tester.tap(opcion);
    await tester.pumpAndSettle();
    expect(simulator.value, isTrue);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);

    // Otra vez: se apaga.
    await tester.tap(find.byType(Switch));
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    final opcionDeNuevo = find.text('Simular caída de la API (solo pruebas)');
    await tester.ensureVisible(opcionDeNuevo);
    await tester.pumpAndSettle();
    await tester.tap(opcionDeNuevo);
    await tester.pumpAndSettle();
    expect(simulator.value, isFalse);
  });
}
