import 'package:flutter/material.dart';
import 'package:pokedex/core/widgets/pixel_panel.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Aviso de datos que todavía no se descargaron (se bajan al abrir el
/// Pokémon con conexión). Cuando llegan, la pantalla se actualiza sola.
class PokemonDetailExtrasPending extends StatelessWidget {
  const PokemonDetailExtrasPending({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return PixelPanel(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          l10n.detailExtrasPending,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
