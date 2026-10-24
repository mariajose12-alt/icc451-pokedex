import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/core/errors/failures.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_bloc.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_event.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_state.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/catalog_message_view.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_card.dart';
import 'package:pokedex/l10n/app_localizations.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/catalog_skeleton.dart';

/// Pantalla del catálogo. Solo conoce el Bloc: nunca la red ni la base.
class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navPokedex)),
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
            case CatalogSuccess(
              :final pokemon,
              :final isRefreshing,
              :final refreshFailure,
            ):
              return Column(
                children: [
                  if (isRefreshing) const LinearProgressIndicator(),
                  if (refreshFailure != null)
                    Material(
                      color: colors.errorContainer,
                      child: ListTile(
                        iconColor: colors.onErrorContainer,
                        textColor: colors.onErrorContainer,
                        leading: const Icon(Icons.cloud_off_outlined),
                        title: Text(l10n.catalogRefreshFailedBanner),
                        trailing: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: colors.onErrorContainer,
                          ),
                          onPressed: () {
                            context.read<CatalogBloc>().add(
                              const CatalogRefreshRequested(),
                            );
                          },
                          child: Text(l10n.retry),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Center(
                      // En pantallas anchas la lista no se estira (RF-CAT-06).
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 640),
                        child: RefreshIndicator(
                          onRefresh: () async {
                            context.read<CatalogBloc>().add(
                              const CatalogRefreshRequested(),
                            );
                          },
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(8),
                            itemCount: pokemon.length,
                            itemBuilder: (context, index) {
                              return PokemonCard(
                                pokemon: pokemon[index],
                                onTap: () {},
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
          }
        },
      ),
    );
  }
}
