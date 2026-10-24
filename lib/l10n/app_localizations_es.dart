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
  String get catalogEmptyMessage =>
      'Conéctate a Internet para descargar el catálogo. Después podrás usarlo sin conexión.';

  @override
  String get catalogErrorTitle => 'No se pudo cargar el catálogo';

  @override
  String get catalogRefreshFailedBanner =>
      'No se pudo actualizar. Mostrando los datos guardados.';

  @override
  String get errorNoConnection =>
      'No hay conexión a Internet. Revisa tu red e inténtalo de nuevo.';

  @override
  String get errorTimeout =>
      'La solicitud tardó demasiado. Inténtalo de nuevo.';

  @override
  String get errorRateLimit =>
      'Se hicieron demasiadas solicitudes. Espera un momento e inténtalo de nuevo.';

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
}
