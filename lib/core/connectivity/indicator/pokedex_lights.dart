import 'package:flutter/material.dart';
import 'package:pokedex/core/theme/pixel_palette.dart';

/// Cuál de las tres luces está encendida.
enum IndicatorLed { red, yellow, green, none }

/// Lente azul de la Pokédex con un icono adentro.
/// Si [pulsing] es true, el borde brilla y se apaga despacio (sincronizando).
class PokedexLens extends StatefulWidget {
  const PokedexLens({required this.icon, required this.pulsing, super.key});

  final IconData icon;
  final bool pulsing;

  @override
  State<PokedexLens> createState() => _PokedexLensState();
}

class _PokedexLensState extends State<PokedexLens>
    with SingleTickerProviderStateMixin {
  // Un ciclo completo de brillo dura 1.4 segundos.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateAnimation();
  }

  @override
  void didUpdateWidget(PokedexLens oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimation();
  }

  // Enciende o apaga el latido según el estado y la configuración del sistema.
  void _updateAnimation() {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    if (widget.pulsing && !reduceMotion) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // glow va de 0 (apagado) a 1 (brillo máximo).
        final glow = _controller.value;

        return SizedBox(
          width: 48,
          height: 48,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: PixelPalette.lens,
              border: Border.all(color: PixelPalette.text, width: 3),
              boxShadow: [
                // Aro de brillo, sin desenfoque, para mantener el estilo pixel.
                BoxShadow(
                  color: PixelPalette.lens.withValues(alpha: glow * 0.8),
                  spreadRadius: glow * 6,
                ),
                // Sombra dura, igual que los paneles de la app.
                const BoxShadow(
                  color: PixelPalette.shadow,
                  offset: Offset(3, 3),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(widget.icon, color: PixelPalette.text, size: 24),
                // Reflejo del cristal, arriba a la izquierda.
                Positioned(
                  left: 7,
                  top: 6,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: PixelPalette.text.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Las tres luces (roja, amarilla, verde) dentro de una cápsula oscura.
class PokedexLeds extends StatelessWidget {
  const PokedexLeds({required this.lit, super.key});

  final IndicatorLed lit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: PixelPalette.shadow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Led(
              on: lit == IndicatorLed.red,
              onColor: const Color(0xFFFF5A5A),
              offColor: const Color(0xFF4A1C1C),
            ),
            const SizedBox(width: 6),
            _Led(
              on: lit == IndicatorLed.yellow,
              onColor: PixelPalette.accent,
              offColor: const Color(0xFF5A4A12),
            ),
            const SizedBox(width: 6),
            _Led(
              on: lit == IndicatorLed.green,
              onColor: PixelPalette.success,
              offColor: const Color(0xFF1F4A2A),
            ),
          ],
        ),
      ),
    );
  }
}

// Una sola luz: encendida (color vivo) o apagada (color oscuro).
class _Led extends StatelessWidget {
  const _Led({required this.on, required this.onColor, required this.offColor});

  final bool on;
  final Color onColor;
  final Color offColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: on ? onColor : offColor,
        border: Border.all(color: PixelPalette.panelBorder, width: 2),
      ),
    );
  }
}
