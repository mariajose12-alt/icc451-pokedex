import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Forma de mostrar el catálogo.
enum CatalogViewMode { grid, list }

/// Modo de vista elegido. Se guarda en el dispositivo y se conserva entre
/// sesiones (RF-FIL-04).
class CatalogViewModeCubit extends Cubit<CatalogViewMode> {
  CatalogViewModeCubit({required SharedPreferences preferences})
    : _preferences = preferences,
      super(
        preferences.getString(_key) == 'list'
            ? CatalogViewMode.list
            : CatalogViewMode.grid,
      );

  static const String _key = 'catalog_view_mode';

  final SharedPreferences _preferences;

  Future<void> select(CatalogViewMode mode) async {
    emit(mode);
    await _preferences.setString(_key, mode.name);
  }
}
