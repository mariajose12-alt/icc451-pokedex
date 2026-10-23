import 'package:flutter/material.dart';

/*
import 'package:pokedex/core/network/api_config.dart';
import 'package:pokedex/core/network/network_exceptions.dart';
import 'package:pokedex/core/network/poke_api_client.dart';

// MAIN PARA PRUEBAS CON LA CONEXION A LA API Y SUS RESPUESTAS
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final client = PokeApiClient(
    url: ApiConfig.graphqlUrl,
    timeout: ApiConfig.requestTimeout,
  );

  try {
    final data = await client.query(
      r'query { pokemon(limit: 3, order_by: {id: asc}) { id name } }',
    );
    debugPrint('OK: $data');
  } on PokeApiException catch (e) {
    debugPrint('Error tipado: $e');
  }

  runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Prueba')))));
}
*/

import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'core/di/app_bloc_observer.dart';
import 'core/di/service_locator.dart';
import 'core/network/api_config.dart';
import 'core/network/poke_api_client.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Observa todos los cambios de estado de los Blocs.
  Bloc.observer = AppBlocObserver();

  // Registro de dependencias
  // Orden: de abajo hacia arriba (red/base de datos -> fuentes de datos
  // -> repositorios). Cada sección se agrega en su tarea.

  // Red
  getIt.registerSingleton<PokeApiClient>(
    PokeApiClient(url: ApiConfig.graphqlUrl, timeout: ApiConfig.requestTimeout),
  );

  // Base de datos

  // Repositorios

  runApp(const PokedexApp());
}
