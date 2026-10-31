import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/core/errors/failures.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_bloc.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_event.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_state.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/catalog_message_view.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/catalog_results.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/catalog_skeleton.dart';
import 'package:pokedex/l10n/app_localizations.dart';

import '../widgets/refresh_failed_toast.dart';

/// Pantalla del catálogo. Solo conoce el Bloc: nunca la red ni la base.
class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // El BlocListener ejecuta una acción (mostrar el toast) cuando el estado
    // cambia; el BlocBuilder de adentro solo dibuja. Son cosas distintas.
    return BlocListener<CatalogBloc, CatalogState>(
      // Se avisa SOLO cuando aparece un fallo nuevo sobre datos existentes:
      // el estado actual tiene fallo y el anterior no lo tenía.
      listenWhen: (previous, current) {
        if (current is! CatalogSuccess || current.refreshFailure == null) {
          return false;
        }
        final hadFailure =
            previous is CatalogSuccess && previous.refreshFailure != null;
        return !hadFailure;
      },
      listener: (context, state) {
        // Si había otro aviso en pantalla, se quita para no acumularlos.
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        const duration = Duration(seconds: 5);
        messenger.showSnackBar(
          SnackBar(
            // El diseño lo pone nuestro widget: el SnackBar solo lo contiene.
            backgroundColor: Colors.transparent,
            elevation: 0,
            padding: EdgeInsets.zero,
            behavior: SnackBarBehavior.floating,
            duration: duration,
            content: RefreshFailedToast(
              duration: duration,
              onRetry: () {
                context.read<CatalogBloc>().add(
                  const CatalogRefreshRequested(),
                );
              },
            ),
          ),
        );
      },
      child: Scaffold(
        body: BlocBuilder<CatalogBloc, CatalogState>(
          builder: (context, state) {
            switch (state) {
              // Cargando por primera vez.
              case CatalogInitial() || CatalogLoading():
                return const CatalogSkeleton();

              // Sin datos y sin nada en curso (RF-CAT-04, PA-15).
              case CatalogEmpty():
                return CatalogMessageView(
                  icon: Icons.cloud_download_outlined,
                  title: l10n.catalogEmptyTitle,
                  message: l10n.catalogEmptyMessage,
                  actionLabel: l10n.refresh,
                  onAction: () {
                    context.read<CatalogBloc>().add(
                      const CatalogRefreshRequested(),
                    );
                  },
                );

              // Sin datos y la actualización falló.
              case CatalogFailure(:final failure):
                final message = switch (failure) {
                  NoConnectionFailure() => l10n.errorNoConnection,
                  TimeoutFailure() => l10n.errorTimeout,
                  RateLimitFailure() => l10n.errorRateLimit,
                  ServiceFailure() => l10n.errorService,
                  UnknownFailure() => l10n.errorUnknown,
                };
                return CatalogMessageView(
                  icon: Icons.cloud_off_outlined,
                  title: l10n.catalogErrorTitle,
                  message: message,
                  actionLabel: l10n.retry,
                  onAction: () {
                    context.read<CatalogBloc>().add(
                      const CatalogRefreshRequested(),
                    );
                  },
                );

              // Hay datos: se muestran siempre, aunque la actualización falle.
              // El aviso de fallo ya no vive aquí: sale como toast arriba.
              case CatalogSuccess(:final pokemon, :final isRefreshing):
                return Column(
                  children: [
                    if (isRefreshing) const LinearProgressIndicator(),
                    Expanded(child: CatalogResults(pokemon: pokemon)),
                  ],
                );
            }
          },
        ),
      ),
    );
  }
}
