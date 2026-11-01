import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/core/network/api_outage_simulator.dart';
import 'package:pokedex/core/network/simulated_outage_poke_api_client.dart';
import 'package:pokedex/features/pokemon/data/sync/catalog_sync_scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'core/connectivity/api_connectivity_monitor.dart';
import 'core/connectivity/connectivity_monitor.dart';
import 'core/di/app_bloc_observer.dart';
import 'core/di/service_locator.dart';
import 'core/network/api_config.dart';
import 'core/network/poke_api_client.dart';
import 'core/sync/sync_info.dart';
import 'features/pokemon/domain/repositories/pokemon_repository.dart';
import 'features/settings/presentation/cubit/locale_cubit.dart';
import 'core/database/app_database.dart';
import 'core/sync/drift_sync_info_source.dart';
import 'core/sync/sync_status.dart';
import 'features/pokemon/data/datasources/local/pokemon_local_datasource.dart';
import 'features/pokemon/data/datasources/remote/pokemon_remote_datasource.dart';
import 'features/pokemon/data/repositories/offline_first_pokemon_repository.dart';
import 'features/pokemon/data/sync/catalog_sync_coordinator.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Observa todos los cambios de estado de los Blocs.
  Bloc.observer = AppBlocObserver();

  // Preferencias del usuario
  final preferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(preferences);

  // Registro de dependencias
  // Orden: de abajo hacia arriba (red/base de datos -> fuentes de datos
  // -> repositorios). Cada sección se agrega en su tarea.

  // Red
  // Simulador de caída de la API (PA-08). Solo se registra en debug, o en
  // release si se compila con --dart-define=API_SIMULATOR=true.
  const simulatorEnabled = bool.fromEnvironment(
    'API_SIMULATOR',
    defaultValue: kDebugMode,
  );
  final outageSimulator = ApiOutageSimulator();
  if (simulatorEnabled) {
    getIt.registerSingleton<ApiOutageSimulator>(outageSimulator);
  }
  getIt.registerSingleton<PokeApiClient>(
    SimulatedOutagePokeApiClient(
      url: ApiConfig.graphqlUrl,
      timeout: ApiConfig.requestTimeout,
      simulator: outageSimulator,
    ),
  );

  // Conectividad
  getIt.registerSingleton<ConnectivityMonitor>(
    ApiConnectivityMonitor(
      connectivity: Connectivity(),
      client: getIt<PokeApiClient>(),
    ),
  );
  // Sin await: la app no debe esperar a la red para abrirse (OF-03).
  unawaited(getIt<ConnectivityMonitor>().start());

  // Base de datos
  // Abre el archivo pokedex.sqlite del teléfono (se crea la primera vez).
  final database = AppDatabase.archivo();
  getIt.registerSingleton<AppDatabase>(database);

  // Fuentes de datos: una habla con la API y otra con la base local.
  final remote = PokemonRemoteDataSource(client: getIt<PokeApiClient>());
  final local = PokemonLocalDataSource(dao: database.catalogoDao);

  // Sincronizador: descarga el catálogo a la base, por páginas (T-014).
  final coordinator = CatalogSyncCoordinator(remote: remote, local: local);
  getIt.registerSingleton<CatalogSyncCoordinator>(coordinator);

  // Repositorios
  // Repositorio real: la pantalla lee de la base y la red solo la escribe.
  getIt.registerSingleton<PokemonRepository>(
    OfflineFirstPokemonRepository(local: local, sync: coordinator),
  );

  // Información de sincronización para el indicador (reemplaza a la falsa).
  getIt.registerSingleton<SyncInfoSource>(
    DriftSyncInfoSource(
      dao: database.catalogoDao,
      resourceKey: SyncResources.catalog,
      runningChanges: coordinator.runningChanges,
      initiallyRunning: coordinator.isRunning,
    ),
  );

  // Programador: decide cuándo se actualiza solo (reconexión y periódica).
  // Va al final porque necesita el monitor y el repositorio ya registrados.
  final scheduler = CatalogSyncScheduler(
    monitor: getIt<ConnectivityMonitor>(),
    repository: getIt<PokemonRepository>(),
  );
  getIt.registerSingleton<CatalogSyncScheduler>(scheduler);
  scheduler.start();

  runApp(PokedexApp(localeCubit: LocaleCubit(preferences: preferences)));
}
