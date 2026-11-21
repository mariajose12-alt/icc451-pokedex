import 'package:flutter/widgets.dart';
import 'package:pokedex/features/pokemon/presentation/share/pokemon_card_sharer.dart';

/// Sharer falso: cuenta las llamadas y puede fallar a propósito.
class FakePokemonCardSharer implements PokemonCardSharer {
  int calls = 0;
  String? lastFileName;
  String? lastText;
  bool shouldFail = false;

  @override
  Future<void> shareCard({
    required GlobalKey boundaryKey,
    required String fileName,
    required String text,
  }) async {
    calls++;
    lastFileName = fileName;
    lastText = text;
    if (shouldFail) {
      throw StateError('falló a propósito');
    }
  }
}
