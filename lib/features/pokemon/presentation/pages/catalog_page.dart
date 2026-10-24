import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/core/errors/failures.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_bloc.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_event.dart';
import 'package:pokedex/features/pokemon/presentation/bloc/catalog_state.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/catalog_message_view.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_card.dart';

/// Pantalla del catálogo. Solo conoce el Bloc: nunca la red ni la base.
class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Pokédex')),
      body: BlocBuilder<CatalogBloc, CatalogState>(
        builder: (context, state) {
          switch (state) {
            // Cargando por primera vez.
            case CatalogInitial() || CatalogLoading():
              return const Center(child: CircularProgressIndicator());

            // Sin datos y sin nada en curso (RF-CAT-04, PA-15).
            case CatalogEmpty():
              return CatalogMessageView(
                icon: Icons.cloud_download_outlined,
                title: 'Aún no hay Pokémon guardados',
                message:
                    'Conéctate a Internet para descargar el catálogo. '
                    'Después podrás usarlo sin conexión.',
                actionLabel: 'Actualizar',
                onAction: () {
                  context.read<CatalogBloc>().add(
                    const CatalogRefreshRequested(),
                  );
                },
              );

            // Sin datos y la actualización falló.
            case CatalogFailure(:final failure):
              final message = switch (failure) {
                NoConnectionFailure() => 'No hay conexión a Internet. Revisa tu red e inténtalo de nuevo.',
                TimeoutFailure() =>
                  'La solicitud tardó demasiado. Inténtalo de nuevo.',
                RateLimitFailure() => 'Se hicieron demasiadas solicitudes. Espera un momento e inténtalo de nuevo.',
                ServiceFailure() =>
                  'El servicio no está disponible en este momento.',
                UnknownFailure() => 'Ocurrió un error inesperado.',
              };
              return CatalogMessageView(
                icon: Icons.cloud_off_outlined,
                title: 'No se pudo cargar el catálogo',
                message: message,
                actionLabel: 'Reintentar',
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
                        title: const Text(
                          'No se pudo actualizar. Mostrando los datos guardados.',
                        ),
                        trailing: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: colors.onErrorContainer,
                          ),
                          onPressed: () {
                            context.read<CatalogBloc>().add(
                              const CatalogRefreshRequested(),
                            );
                          },
                          child: const Text('Reintentar'),
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
