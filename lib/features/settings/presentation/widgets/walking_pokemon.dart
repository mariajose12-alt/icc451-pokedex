import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/core/cache/image_cache_manager.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';
import 'package:pokedex/features/settings/domain/repositories/saved_pokemon_repository.dart';

/// Adorno: un Pokémon al azar camina de lado a lado sobre una línea de suelo.
/// Es solo decoración: no se toca ni lo lee el lector de pantalla.
class WalkingPokemon extends StatefulWidget {
  const WalkingPokemon({required this.repository, super.key});

  final SavedPokemonRepository repository;

  @override
  State<WalkingPokemon> createState() => _WalkingPokemonState();
}

class _WalkingPokemonState extends State<WalkingPokemon>
    with SingleTickerProviderStateMixin {
  static const double _height = 64;
  static const double _size = 56;

  // Una vuelta completa (ida o regreso) tarda 9 s.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 9),
  );

  String? _url;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  /// Elige el sprite: de 12 al azar, el primero que ya esté guardado en el
  /// teléfono (funciona sin conexión). Si ninguno, el primero.
  Future<void> _load() async {
    final urls = await widget.repository.randomSpriteUrls(12);
    if (urls.isEmpty) return;

    var chosen = urls.first;
    try {
      for (final url in urls) {
        final info = await ImageCacheManager.instance.getFileFromCache(url);
        if (info != null && await info.file.exists()) {
          chosen = url;
          break;
        }
      }
    } on Object catch (_) {
      // Si la caché falla, se usa el primero y ya.
    }
    if (mounted) setState(() => _url = chosen);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Con «reducir animaciones» el Pokémon se queda quieto (RNF-ACC).
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      unawaited(_controller.repeat(reverse: true));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Con el texto muy grande no se gasta espacio en un adorno.
    if (MediaQuery.textScalerOf(context).scale(1) > 1.3) {
      return const SizedBox.shrink();
    }

    final url = _url;
    // Altura fija mientras carga: la pantalla no salta cuando aparece.
    if (url == null) return const SizedBox(height: _height);

    return ExcludeSemantics(
      child: RepaintBoundary(
        child: SizedBox(
          height: _height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxX = math.max(0.0, constraints.maxWidth - _size);
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final t = _controller.value;
                  // Saltitos: 8 por vuelta.
                  final hop = math.sin(t * math.pi * 2 * 8).abs() * 4;
                  // Los sprites miran a la izquierda: se voltean al ir a la derecha.
                  final goingRight =
                      _controller.status != AnimationStatus.reverse;
                  return Stack(
                    children: [
                      Positioned(
                        left: maxX * t,
                        bottom: -10 + hop,
                        child: Transform.flip(flipX: goingRight, child: child),
                      ),
                    ],
                  );
                },
                // La imagen no cambia: se construye una vez, solo se mueve.
                child: CachedNetworkImage(
                  imageUrl: url,
                  cacheManager: ImageCacheManager.instance,
                  width: _size,
                  height: _size,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                  memCacheWidth: 112,
                  placeholder: (context, url) => const SizedBox.shrink(),
                  errorWidget: (context, url, error) => const SizedBox.shrink(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
