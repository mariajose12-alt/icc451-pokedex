import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Idioma elegido por el usuario. `null` significa «seguir el del sistema».
/// La elección se guarda en el dispositivo y sobrevive al reinicio.
class LocaleCubit extends Cubit<Locale?> {
  LocaleCubit({required SharedPreferences preferences})
    : _preferences = preferences,
      super(
        preferences.getString(_key) == null
            ? null
            : Locale(preferences.getString(_key)!),
      );

  static const String _key = 'language_code';

  final SharedPreferences _preferences;

  /// Cambia el idioma; `null` vuelve al idioma del sistema.
  Future<void> select(Locale? locale) async {
    emit(locale);
    if (locale == null) {
      await _preferences.remove(_key);
    } else {
      await _preferences.setString(_key, locale.languageCode);
    }
  }
}
