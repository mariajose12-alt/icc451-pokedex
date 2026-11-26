import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pokedex/core/connectivity/indicator/pokedex_lights.dart';
import 'package:pokedex/core/theme/pixel_colors.dart';
import 'package:pokedex/core/widgets/pixel_panel.dart';
import 'package:pokedex/core/widgets/pixel_sprite.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Introducción de cuatro pasos con mini-práctica (RF-COM-08). Cada paso tiene
/// una demo táctil con datos de ejemplo (sin red ni base de datos) y una pista
/// de dónde está esa función en la app. La pantalla no sabe dónde se guarda
/// que ya se vio: al terminar o saltar llama a [onFinished].
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({required this.onFinished, super.key});

  final Future<void> Function() onFinished;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const int _steps = 4;

  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Pasa al paso siguiente; sin animación si el sistema pide reducirlas.
  // (nextPage no acepta duración cero, por eso se salta con jumpToPage.)
  void _next() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(_index + 1);
      return;
    }
    unawaited(
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.pixel;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final isLast = _index == _steps - 1;

    final titles = [
      l10n.onboardingTitle1,
      l10n.onboardingTitle2,
      l10n.onboardingTitle3,
      l10n.onboardingTitle4,
    ];
    final bodies = [
      l10n.onboardingBody1,
      l10n.onboardingBody2,
      l10n.onboardingBody3,
      l10n.onboardingBody4,
    ];
    // Qué pestaña se resalta en la mini barra (null = el paso no es de una
    // pestaña, sino del indicador de arriba).
    final tabs = <int?>[0, 1, null, 2];
    final demos = <Widget>[
      const _ExploreDemo(),
      const _FavoriteDemo(),
      const _LensDemo(),
      const _TriviaDemo(),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.onboardingStep(_index + 1, _steps),
                      style: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(color: colors.textMuted),
                    ),
                  ),
                  // Saltar se oculta (pero ocupa su lugar) en el último paso.
                  Visibility(
                    visible: !isLast,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                      onPressed: () => unawaited(widget.onFinished()),
                      child: Text(l10n.onboardingSkip),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _steps,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, i) => _StepView(
                  title: titles[i],
                  body: bodies[i],
                  selectedTab: tabs[i],
                  demo: demos[i],
                ),
              ),
            ),
            // Puntos de progreso.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _steps; i++)
                  AnimatedContainer(
                    duration: reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _index ? 24 : 10,
                    height: 10,
                    color: i == _index ? colors.accent : colors.panelBorder,
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: isLast
                      ? () => unawaited(widget.onFinished())
                      : _next,
                  child: Text(
                    isLast ? l10n.onboardingStart : l10n.onboardingNext,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Un paso: título, texto, la demo y la pista de dónde está. Se puede
/// desplazar para que con texto grande (200 %) no se corte nada.
class _StepView extends StatelessWidget {
  const _StepView({
    required this.title,
    required this.body,
    required this.selectedTab,
    required this.demo,
  });

  final String title;
  final String body;
  final int? selectedTab;
  final Widget demo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.pixel;
    final textTheme = Theme.of(context).textTheme;
    final tabNames = [
      l10n.navPokedex,
      l10n.navFavorites,
      l10n.navTrivia,
      l10n.navSettings,
    ];
    final tab = selectedTab;
    final where = tab == null
        ? l10n.onboardingWhereTop
        : l10n.onboardingWhereTab(tabNames[tab]);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                color: colors.text,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: 20),
          demo,
          const SizedBox(height: 20),
          // Dónde está en la app real.
          Text(
            where,
            textAlign: TextAlign.center,
            style: textTheme.labelLarge?.copyWith(color: colors.accentText),
          ),
          const SizedBox(height: 8),
          if (tab == null)
            Icon(Icons.arrow_upward, color: colors.accentText)
          else
            _MiniNav(selected: tab, labels: tabNames),
        ],
      ),
    );
  }
}

/// Réplica pequeña de la barra de pestañas con una resaltada. Es solo una
/// ilustración: no se toca y los lectores de pantalla leen la línea «Dónde».
class _MiniNav extends StatelessWidget {
  const _MiniNav({required this.selected, required this.labels});

  final int selected;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final colors = context.pixel;
    final sprites = [
      PixelSprites.ball,
      PixelSprites.heart,
      PixelSprites.quiz,
      PixelSprites.gear,
    ];

    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.panel,
          border: Border.all(color: colors.panelBorder, width: 3),
        ),
        child: Row(
          children: [
            for (var i = 0; i < sprites.length; i++)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  color: i == selected ? colors.accent : null,
                  child: Column(
                    children: [
                      PixelSprite(
                        sprite: sprites[i],
                        color: i == selected ? colors.onAccent : colors.text,
                        width: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: i == selected ? colors.onAccent : colors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Marco común de una demo: el contenido y debajo una línea que primero invita
/// a probar y, al hacerlo, confirma lo que pasó.
class _DemoFrame extends StatelessWidget {
  const _DemoFrame({
    required this.child,
    required this.hint,
    required this.doneText,
    required this.done,
  });

  final Widget child;
  final String hint;
  final String doneText;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final colors = context.pixel;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        child,
        const SizedBox(height: 12),
        // liveRegion: el lector de pantalla anuncia el cambio al probar.
        Semantics(
          liveRegion: true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                done ? Icons.check_circle : Icons.touch_app,
                size: 20,
                color: done ? colors.success : colors.accentText,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  done ? doneText : hint,
                  style: textTheme.bodyMedium?.copyWith(
                    color: done ? colors.success : colors.accentText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Paso 1: tarjeta de práctica que se abre.
// ---------------------------------------------------------------------------

class _ExploreDemo extends StatefulWidget {
  const _ExploreDemo();

  @override
  State<_ExploreDemo> createState() => _ExploreDemoState();
}

class _ExploreDemoState extends State<_ExploreDemo> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.pixel;
    final textTheme = Theme.of(context).textTheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            PixelSprite(
              sprite: PixelSprites.ball,
              color: colors.accentText,
              width: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '#025  Pikachu',
                style: textTheme.titleMedium?.copyWith(
                  color: colors.text,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        if (_open) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              color: colors.accent,
              child: Text(
                l10n.onboardingDemoType,
                style: textTheme.labelLarge?.copyWith(
                  color: colors.onAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${l10n.onboardingDemoSpeed}  90',
            style: textTheme.bodyMedium?.copyWith(color: colors.text),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: 0.9,
            minHeight: 10,
            color: colors.accent,
            backgroundColor: colors.panelHigh,
          ),
        ],
      ],
    );

    return _DemoFrame(
      done: _open,
      hint: l10n.onboardingTryCard,
      doneText: l10n.onboardingDoneCard,
      child: Semantics(
        button: true,
        label: l10n.onboardingDemoCardLabel,
        excludeSemantics: true,
        child: PixelPanel(
          onTap: () => setState(() => _open = !_open),
          // Con animaciones reducidas se abre de golpe. (AnimatedSize no
          // acepta duración cero: falla al recalcular su tamaño.)
          child: reduceMotion
              ? content
              : AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.topCenter,
                  child: content,
                ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Paso 2: corazón de práctica.
// ---------------------------------------------------------------------------

class _FavoriteDemo extends StatefulWidget {
  const _FavoriteDemo();

  @override
  State<_FavoriteDemo> createState() => _FavoriteDemoState();
}

class _FavoriteDemoState extends State<_FavoriteDemo> {
  bool _favorite = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.pixel;
    final textTheme = Theme.of(context).textTheme;

    return _DemoFrame(
      done: _favorite,
      hint: l10n.onboardingTryHeart,
      doneText: l10n.onboardingDoneHeart,
      child: PixelPanel(
        child: Row(
          children: [
            PixelSprite(
              sprite: PixelSprites.ball,
              color: colors.accentText,
              width: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '#025  Pikachu',
                style: textTheme.titleMedium?.copyWith(
                  color: colors.text,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              tooltip: _favorite
                  ? l10n.onboardingDemoUnfavorite
                  : l10n.onboardingDemoFavorite,
              onPressed: () => setState(() => _favorite = !_favorite),
              icon: Icon(
                _favorite ? Icons.favorite : Icons.favorite_border,
                color: _favorite ? colors.shell : colors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Paso 3: lente de práctica que cambia de estado.
// ---------------------------------------------------------------------------

class _LensDemo extends StatefulWidget {
  const _LensDemo();

  @override
  State<_LensDemo> createState() => _LensDemoState();
}

class _LensDemoState extends State<_LensDemo> {
  int _state = 0;
  bool _touched = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.pixel;
    final textTheme = Theme.of(context).textTheme;

    // Los mismos estados y textos que el indicador real.
    final states = <({IconData icon, IndicatorLed led, String title})>[
      (
        icon: Icons.cloud_done,
        led: IndicatorLed.green,
        title: l10n.indicatorOnline,
      ),
      (icon: Icons.sync, led: IndicatorLed.green, title: l10n.indicatorSyncing),
      (
        icon: Icons.cloud_off,
        led: IndicatorLed.red,
        title: l10n.indicatorOffline,
      ),
      (
        icon: Icons.warning_amber,
        led: IndicatorLed.yellow,
        title: l10n.indicatorUnavailable,
      ),
    ];
    final current = states[_state];

    return _DemoFrame(
      done: _touched,
      hint: l10n.onboardingTryLens,
      doneText: l10n.onboardingDoneLens,
      child: Semantics(
        button: true,
        label: l10n.onboardingDemoLensLabel,
        value: current.title,
        excludeSemantics: true,
        child: PixelPanel(
          onTap: () => setState(() {
            _touched = true;
            _state = (_state + 1) % states.length;
          }),
          child: Row(
            children: [
              PokedexLens(icon: current.icon, pulsing: _state == 1),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  current.title,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              PokedexLeds(lit: current.led),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Paso 4: «?» de la trivia que se revela.
// ---------------------------------------------------------------------------

class _TriviaDemo extends StatefulWidget {
  const _TriviaDemo();

  @override
  State<_TriviaDemo> createState() => _TriviaDemoState();
}

class _TriviaDemoState extends State<_TriviaDemo> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.pixel;
    final textTheme = Theme.of(context).textTheme;

    return _DemoFrame(
      done: _revealed,
      hint: l10n.onboardingTryQuestion,
      doneText: l10n.onboardingDoneQuestion,
      child: Semantics(
        button: true,
        label: l10n.onboardingDemoQuestionLabel,
        excludeSemantics: true,
        child: PixelPanel(
          onTap: () => setState(() => _revealed = !_revealed),
          child: Container(
            height: 110,
            alignment: Alignment.center,
            color: colors.panelHigh,
            child: _revealed
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PixelSprite(
                        sprite: PixelSprites.ball,
                        color: colors.accentText,
                        width: 48,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pikachu',
                        style: textTheme.titleMedium?.copyWith(
                          color: colors.text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Text(
                    '?',
                    style: textTheme.displayMedium?.copyWith(
                      color: colors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
