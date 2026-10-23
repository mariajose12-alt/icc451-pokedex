import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/app/app.dart';

void main() {
  testWidgets('La app abre en la Pokédex y navega a Favoritos', (tester) async {
    await tester.pumpWidget(const PokedexApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Pokédex'), findsWidgets);

    await tester.tap(find.text('Favoritos'));
    await tester.pumpAndSettle();

    expect(find.text('Favoritos'), findsWidgets);
  });
}
