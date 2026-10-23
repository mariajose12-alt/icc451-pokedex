import 'package:flutter/material.dart';

/// Pantalla del catálogo. Provisional: se implementa en T-015.
class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokédex')),
      body: const Center(child: Text('Pokédex')),
    );
  }
}
