import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tema elegido por el usuario: claro, oscuro o «seguir el del sistema»
/// (RF-COM-06). La elección se guarda en el dispositivo y sobrevive al reinicio,
/// igual que el idioma.
class ThemeModeCubit extends Cubit<ThemeMode> {
  ThemeModeCubit({required SharedPreferences preferences})
    : _preferences = preferences,
      super(_read(preferences));

  static const String _key = 'theme_mode';

  final SharedPreferences _preferences;

  // Lee lo guardado. Si no hay nada (o el valor es raro), sigue al sistema.
  static ThemeMode _read(SharedPreferences preferences) {
    return switch (preferences.getString(_key)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  /// Cambia el tema. `ThemeMode.system` borra la elección guardada.
  Future<void> select(ThemeMode mode) async {
    emit(mode);
    if (mode == ThemeMode.system) {
      await _preferences.remove(_key);
    } else {
      await _preferences.setString(_key, mode.name);
    }
  }
}
