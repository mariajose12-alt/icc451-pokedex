import 'package:flutter/foundation.dart';

/// Interruptor que simula la caída de la API (prueba PA-08).
/// Vale true cuando la API debe "estar caída". Al ser un ValueNotifier,
/// quien lo escuche (el interruptor de la pantalla) se redibuja solo.
class ApiOutageSimulator extends ValueNotifier<bool> {
  ApiOutageSimulator() : super(false);

  bool get isDown => value;
}
