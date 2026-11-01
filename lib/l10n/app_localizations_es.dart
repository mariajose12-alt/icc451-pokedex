// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Pokédex';

  @override
  String get navPokedex => 'Pokédex';

  @override
  String get navFavorites => 'Favoritos';

  @override
  String get navTrivia => 'Trivia';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get loading => 'Cargando';

  @override
  String get retry => 'Reintentar';

  @override
  String get refresh => 'Actualizar';

  @override
  String get catalogEmptyTitle => 'Aún no hay Pokémon guardados';

  @override
  String get catalogEmptyMessage => 'Conéctate a Internet para descargar el catálogo. Después podrás usarlo sin conexión.';

  @override
  String get catalogErrorTitle => 'No se pudo cargar el catálogo';

  @override
  String get catalogRefreshFailedBanner => 'No se pudo actualizar. Mostrando los datos guardados.';

  @override
  String get errorNoConnection => 'No hay conexión a Internet. Revisa tu red e inténtalo de nuevo.';

  @override
  String get errorTimeout => 'La solicitud tardó demasiado. Inténtalo de nuevo.';

  @override
  String get errorRateLimit => 'Se hicieron demasiadas solicitudes. Espera un momento e inténtalo de nuevo.';

  @override
  String get errorService => 'El servicio no está disponible en este momento.';

  @override
  String get errorUnknown => 'Ocurrió un error inesperado.';

  @override
  String pokemonSemanticLabel(String name, int number, String types) {
    return '$name, Pokédex número $number, tipos: $types';
  }

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String pokemonCount(int count) {
    return '$count Pokémon';
  }

  @override
  String get viewGrid => 'Cuadrícula';

  @override
  String get viewList => 'Lista';

  @override
  String get indicatorOnline => 'En línea';

  @override
  String get indicatorOffline => 'Sin conexión';

  @override
  String get indicatorUnavailable => 'Servicio no disponible';

  @override
  String get indicatorSyncing => 'Sincronizando…';

  @override
  String get indicatorChecking => 'Verificando…';

  @override
  String indicatorDetailOnline(String sync) {
    return 'Datos remotos · $sync';
  }

  @override
  String indicatorDetailOffline(String sync) {
    return 'Datos locales · $sync';
  }

  @override
  String indicatorDetailUnavailable(String sync) {
    return 'Red activa, API sin respuesta · datos locales · $sync';
  }

  @override
  String get indicatorDetailSyncing => 'En línea · puedes seguir navegando';

  @override
  String get indicatorDetailChecking => 'Comprobando el servicio';

  @override
  String indicatorLastSync(String time) {
    return 'última sync $time';
  }

  @override
  String get indicatorNeverSynced => 'sin sincronizar';

  @override
  String indicatorSemantics(String status, String detail) {
    return 'Estado de conexión: $status. $detail';
  }

  @override
  String get catalogRefreshFailedTitle => 'No se pudo actualizar';

  @override
  String get catalogRefreshFailedMessage => 'Se muestran los datos guardados. Inténtalo de nuevo.';

  @override
  String get debugSimulateOutage => 'Simular caída de la API (solo pruebas)';
}
