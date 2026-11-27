import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/theme/app_theme.dart';
import 'package:pokedex/core/theme/pixel_colors.dart';

void main() {
  testWidgets('context.pixel entrega los colores del tema claro', (
    tester,
  ) async {
    late PixelColors seen;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) {
            seen = context.pixel;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(seen.background, PixelColors.light.background);
    expect(seen.accentText, PixelColors.light.accentText);
  });

  testWidgets('context.pixel entrega los colores del tema oscuro', (
    tester,
  ) async {
    late PixelColors seen;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Builder(
          builder: (context) {
            seen = context.pixel;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(seen.background, PixelColors.dark.background);
  });

  testWidgets('sin tema de la app, context.pixel usa el oscuro', (
    tester,
  ) async {
    late PixelColors seen;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            seen = context.pixel;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(seen.background, PixelColors.dark.background);
  });
}
