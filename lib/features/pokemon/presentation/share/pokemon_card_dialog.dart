import 'package:flutter/material.dart';
import 'package:pokedex/features/pokemon/presentation/share/pokemon_card.dart';
import 'package:pokedex/features/pokemon/presentation/share/pokemon_card_data.dart';
import 'package:pokedex/features/pokemon/presentation/share/pokemon_card_sharer.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Muestra la carta y el botón para compartirla como imagen.
Future<void> showPokemonCardDialog(
  BuildContext context, {
  required PokemonCardData data,
  PokemonCardSharer sharer = const ImagePokemonCardSharer(),
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => _PokemonCardDialog(data: data, sharer: sharer),
  );
}

class _PokemonCardDialog extends StatefulWidget {
  const _PokemonCardDialog({required this.data, required this.sharer});

  final PokemonCardData data;
  final PokemonCardSharer sharer;

  @override
  State<_PokemonCardDialog> createState() => _PokemonCardDialogState();
}

class _PokemonCardDialogState extends State<_PokemonCardDialog> {
  // Marca el RepaintBoundary que se convierte en imagen.
  final _boundaryKey = GlobalKey();
  bool _busy = false;
  bool _failed = false;

  Future<void> _share() async {
    final l10n = AppLocalizations.of(context)!;
    final number = widget.data.nationalDexNumber.toString().padLeft(3, '0');

    setState(() {
      _busy = true;
      _failed = false;
    });

    try {
      await widget.sharer.shareCard(
        boundaryKey: _boundaryKey,
        fileName: 'pokemon-$number.png',
        text: l10n.cardShareText(widget.data.name, number),
      );
      if (mounted) {
        setState(() => _busy = false);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: l10n.detailFormClose,
              icon: const Icon(Icons.close),
              color: Colors.white,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          // La carta mide 378×528: se reduce para caber en pantallas chicas.
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: RepaintBoundary(
                key: _boundaryKey,
                child: PokemonCard(data: widget.data),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_failed)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n.cardShareError,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          FilledButton.icon(
            onPressed: _busy ? null : _share,
            icon: _busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.share),
            label: Text(l10n.cardShareAction),
          ),
        ],
      ),
    );
  }
}
