import 'package:pokedex/features/trivia/data/datasources/local/trivia_image_cache.dart';

/// Caché falsa: las URLs "guardadas" se definen a mano.
class FakeTriviaImageCache implements TriviaImageCache {
  FakeTriviaImageCache([Set<String> cached = const {}]) : cached = {...cached};

  final Set<String> cached;

  @override
  Future<bool> isCached(String url) async => cached.contains(url);
}
