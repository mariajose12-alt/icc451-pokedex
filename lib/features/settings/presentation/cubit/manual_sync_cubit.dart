import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/core/errors/failures.dart';
import 'package:pokedex/features/pokemon/domain/repositories/pokemon_repository.dart';

/// Estados de la sincronización pedida por el usuario.
sealed class ManualSyncState {
  const ManualSyncState();
}

final class ManualSyncIdle extends ManualSyncState {
  const ManualSyncIdle();
}

final class ManualSyncRunning extends ManualSyncState {
  const ManualSyncRunning();
}

final class ManualSyncFailed extends ManualSyncState {
  const ManualSyncFailed(this.failure);

  final Failure failure;
}

/// Sincronización manual (PS-04): descarga el catálogo ahora, sin esperar
/// a la vigencia de 24 h. El resultado llega a la pantalla por la base local;
/// este cubit solo sabe si está corriendo o si falló.
class ManualSyncCubit extends Cubit<ManualSyncState> {
  ManualSyncCubit({required this._repository}) : super(const ManualSyncIdle());

  final PokemonRepository _repository;

  Future<void> sync() async {
    // Un segundo toque mientras corre no lanza otra descarga (RNF-RES-03).
    if (state is ManualSyncRunning) return;

    emit(const ManualSyncRunning());
    try {
      await _repository.refreshCatalog();
      if (!isClosed) emit(const ManualSyncIdle());
    } on Failure catch (failure) {
      if (!isClosed) emit(ManualSyncFailed(failure));
    } on Object catch (_) {
      if (!isClosed) emit(const ManualSyncFailed(UnknownFailure()));
    }
  }
}
