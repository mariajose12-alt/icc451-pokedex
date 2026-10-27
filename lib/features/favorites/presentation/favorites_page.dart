import 'package:flutter/material.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Pantalla de favoritos. Provisional.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navFavorites)),
      body: Center(child: Text(l10n.navFavorites)),
    );
  }
}
