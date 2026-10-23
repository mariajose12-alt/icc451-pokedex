import 'package:get_it/get_it.dart';

/// Contenedor de dependencias de toda la app (service locator).
///
/// Regla: solo la raíz de composición (main.dart y los providers de app/)
/// puede usar [getIt]. Los Blocs y repositorios reciben sus dependencias
/// por constructor, nunca llaman a [getIt] por dentro.
final GetIt getIt = GetIt.instance;
