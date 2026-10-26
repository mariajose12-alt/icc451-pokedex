import 'package:flutter/material.dart';

/// Pantalla del catálogo. Provisional
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokédex')),
      body: const Center(child: Text('Pokédex')),
    );
  }
}
