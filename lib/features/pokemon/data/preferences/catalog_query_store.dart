import 'dart:convert';

import 'package:pokedex/features/pokemon/domain/entities/catalogo_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda y recupera el último criterio del catálogo (RF-FIL-04).
/// Vive en data porque usa SharedPreferences; el Bloc solo ve este contrato.
class CatalogQueryStore {
  CatalogQueryStore({required this._preferences});

  static const String _key = 'catalog_query';

  final SharedPreferences _preferences;

  /// Criterio guardado, o el criterio por defecto si no hay nada o está roto.
  CatalogoQuery load() {
    final raw = _preferences.getString(_key);
    if (raw == null) {
      return const CatalogoQuery();
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return CatalogoQuery(
        nombre: map['nombre'] as String? ?? '',
        tipoIds: _intSet(map['tipoIds']),
        generacionIds: _intSet(map['generacionIds']),
        orden: CatalogoOrden.values.firstWhere(
          (o) => o.name == map['orden'],
          orElse: () => CatalogoOrden.numero,
        ),
      );
    } on FormatException {
      // Un valor corrupto no debe impedir abrir la app: se usa el default.
      return const CatalogoQuery();
    } on TypeError {
      return const CatalogoQuery();
    }
  }

  Future<void> save(CatalogoQuery query) {
    final map = <String, dynamic>{
      'nombre': query.nombre,
      'tipoIds': query.tipoIds.toList(),
      'generacionIds': query.generacionIds.toList(),
      'orden': query.orden.name,
    };
    return _preferences.setString(_key, jsonEncode(map));
  }

  Set<int> _intSet(Object? value) {
    if (value is! List) {
      return const <int>{};
    }
    return value.whereType<int>().toSet();
  }
}
