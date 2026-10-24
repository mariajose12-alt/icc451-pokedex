// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pokédex';

  @override
  String get navPokedex => 'Pokédex';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navTrivia => 'Trivia';

  @override
  String get navSettings => 'Settings';

  @override
  String get loading => 'Loading';

  @override
  String get retry => 'Retry';

  @override
  String get refresh => 'Refresh';

  @override
  String get catalogEmptyTitle => 'No Pokémon saved yet';

  @override
  String get catalogEmptyMessage =>
      'Connect to the Internet to download the catalog. After that you can use it offline.';

  @override
  String get catalogErrorTitle => 'The catalog could not be loaded';

  @override
  String get catalogRefreshFailedBanner =>
      'Could not update. Showing saved data.';

  @override
  String get errorNoConnection =>
      'No Internet connection. Check your network and try again.';

  @override
  String get errorTimeout => 'The request took too long. Try again.';

  @override
  String get errorRateLimit =>
      'Too many requests. Wait a moment and try again.';

  @override
  String get errorService => 'The service is not available right now.';

  @override
  String get errorUnknown => 'An unexpected error occurred.';

  @override
  String pokemonSemanticLabel(String name, int number, String types) {
    return '$name, Pokédex number $number, types: $types';
  }

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'System';
}
