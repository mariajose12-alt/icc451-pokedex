import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/app/router/pokedex_nav_bar.dart';
import 'package:pokedex/core/widgets/pixel_sprite.dart';

void main() {
  Widget barra({
    required int selected,
    required ValueChanged<int> onSelected,
    double textScale = 1,
  }) {
    return MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        bottomNavigationBar: PokedexNavBar(
          selectedIndex: selected,
          onSelected: onSelected,
          items: [
            PokedexNavItem(sprite: PixelSprites.ball, label: 'Pokédex'),
            PokedexNavItem(sprite: PixelSprites.heart, label: 'Favoritos'),
            PokedexNavItem(sprite: PixelSprites.quiz, label: 'Trivia'),
          ],
        ),
      ),
    );
  }

  testWidgets('muestra las tres pestañas y avisa cuál se toca', (tester) async {
    int? tocada;
    await tester.pumpWidget(barra(selected: 0, onSelected: (i) => tocada = i));

    expect(find.text('Pokédex'), findsOneWidget);
    expect(find.text('Favoritos'), findsOneWidget);
    expect(find.text('Trivia'), findsOneWidget);

    await tester.tap(find.text('Trivia'));
    expect(tocada, 2);
  });

  testWidgets('la pestaña activa se marca como seleccionada', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(barra(selected: 1, onSelected: (_) {}));

    expect(
      tester.getSemantics(find.bySemanticsLabel('Favoritos')),
      matchesSemantics(
        label: 'Favoritos',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('con texto al 200 % no se desborda y mide al menos 48 dp', (
    tester,
  ) async {
    await tester.pumpWidget(
      barra(selected: 0, onSelected: (_) {}, textScale: 2),
    );

    expect(tester.takeException(), isNull);
    final alto = tester.getSize(find.text('Favoritos')).height;
    expect(alto, greaterThan(0));
    final boton = tester.getSize(find.byType(InkWell).first);
    expect(boton.height, greaterThanOrEqualTo(48));
  });
}
