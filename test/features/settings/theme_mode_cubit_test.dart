import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/settings/presentation/cubit/theme_mode_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  test('sin nada guardado sigue al sistema', () async {
    final cubit = ThemeModeCubit(preferences: await prefsWith({}));
    addTearDown(cubit.close);

    expect(cubit.state, ThemeMode.system);
  });

  test('recupera el tema guardado al abrir la app', () async {
    final cubit = ThemeModeCubit(
      preferences: await prefsWith({'theme_mode': 'dark'}),
    );
    addTearDown(cubit.close);

    expect(cubit.state, ThemeMode.dark);
  });

  test('un valor desconocido se trata como sistema', () async {
    final cubit = ThemeModeCubit(
      preferences: await prefsWith({'theme_mode': 'morado'}),
    );
    addTearDown(cubit.close);

    expect(cubit.state, ThemeMode.system);
  });

  test('elegir claro lo emite y lo guarda', () async {
    final preferences = await prefsWith({});
    final cubit = ThemeModeCubit(preferences: preferences);
    addTearDown(cubit.close);

    await cubit.select(ThemeMode.light);

    expect(cubit.state, ThemeMode.light);
    expect(preferences.getString('theme_mode'), 'light');
  });

  test('volver a sistema borra lo guardado', () async {
    final preferences = await prefsWith({'theme_mode': 'dark'});
    final cubit = ThemeModeCubit(preferences: preferences);
    addTearDown(cubit.close);

    await cubit.select(ThemeMode.system);

    expect(cubit.state, ThemeMode.system);
    expect(preferences.containsKey('theme_mode'), isFalse);
  });
}
