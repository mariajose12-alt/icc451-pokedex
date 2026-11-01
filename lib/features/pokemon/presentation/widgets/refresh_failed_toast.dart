import 'package:flutter/material.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Tarjeta de aviso "No se pudo actualizar". Se muestra dentro de un
/// SnackBar: icono, título, mensaje, "Reintentar", X para cerrar y una
/// barra que se acorta mientras corre el tiempo.
class RefreshFailedToast extends StatelessWidget {
  const RefreshFailedToast({
    required this.duration,
    required this.onRetry,
    super.key,
  });

  /// Cuánto dura el aviso. La barra de abajo usa el mismo tiempo.
  final Duration duration;

  /// Qué hacer al tocar "Reintentar".
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final messenger = ScaffoldMessenger.of(context);

    return Material(
      color: colors.errorContainer,
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      // Recorta la barra de abajo con las esquinas redondeadas.
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 4, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono de error (no depende solo del color: lleva el "!").
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(Icons.error, color: colors.error),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.catalogRefreshFailedTitle,
                        style: textTheme.titleSmall?.copyWith(
                          color: colors.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.catalogRefreshFailedMessage,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.onErrorContainer,
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: colors.onErrorContainer,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.zero,
                          textStyle: const TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onPressed: () {
                          // Primero se esconde el aviso y luego se reintenta.
                          messenger.hideCurrentSnackBar();
                          onRetry();
                        },
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
                // X para cerrar antes de tiempo.
                IconButton(
                  icon: Icon(Icons.close, color: colors.onErrorContainer),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: messenger.hideCurrentSnackBar,
                ),
              ],
            ),
          ),
          // Barra de cuenta regresiva: va de 1 (llena) a 0 (vacía).
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 1, end: 0),
            duration: duration,
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 4,
                color: colors.error,
                backgroundColor: Colors.transparent,
              );
            },
          ),
        ],
      ),
    );
  }
}
