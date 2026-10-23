import 'package:flutter/material.dart';

/// Temas de la aplicación. El tema oscuro se agrega en T-046.
abstract final class AppTheme {
  /// Color base del que Material 3 deriva todo el esquema (rojo Pokédex).
  static const Color seed = Color(0xFFD32F2F);

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: seed),
    // Mantiene objetivos táctiles de al menos 48x48 dp (RNF-ACC-03).
    materialTapTargetSize: MaterialTapTargetSize.padded,
  );
}
