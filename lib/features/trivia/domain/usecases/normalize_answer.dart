/// Letras con acento que se convierten a su versión simple.
const Map<String, String> _accents = {
  'á': 'a',
  'é': 'e',
  'í': 'i',
  'ó': 'o',
  'ú': 'u',
  'ü': 'u',
  'ñ': 'n',
};

final RegExp _letterOrDigit = RegExp('[a-z0-9]');

/// Deja solo letras y números, en minúscula y sin acentos.
/// Así "Mr. Mime", "mr-mime" y "MR MIME" se vuelven "mrmime".
String normalizeAnswer(String text) {
  final buffer = StringBuffer();
  for (final rune in text.toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    final simple = _accents[char] ?? char;
    if (_letterOrDigit.hasMatch(simple)) {
      buffer.write(simple);
    }
  }
  return buffer.toString();
}

/// ¿Lo que escribió el usuario es el nombre del Pokémon? (RF-TRV-01)
/// Un texto vacío nunca es correcto.
bool isCorrectAnswer({required String typed, required String pokemonName}) {
  final answer = normalizeAnswer(typed);
  if (answer.isEmpty) {
    return false;
  }
  return answer == normalizeAnswer(pokemonName);
}

/// Letras reveladas por las pistas: una por pista, de izquierda a derecha.
/// Nunca se revela el nombre completo.
String revealedLetters({required String pokemonName, required int hintsUsed}) {
  final clean = normalizeAnswer(pokemonName);
  var count = hintsUsed;
  if (count > clean.length - 1) {
    count = clean.length - 1;
  }
  if (count < 0) {
    count = 0;
  }
  return clean.substring(0, count);
}
