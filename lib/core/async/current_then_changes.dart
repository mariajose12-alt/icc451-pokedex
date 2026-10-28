import 'dart:async';

/// Crea un stream que, al suscribirse, emite primero el valor actual
/// y después cada cambio posterior.
///
/// Por qué existe: la versión con `async*` + `yield` dejaba un hueco entre
/// entregar el valor actual y suscribirse a los cambios. Un cambio que llegara
/// en ese hueco se perdía (un controller broadcast descarta lo que se emite sin
/// oyentes). Aquí la suscripción a [changes] se hace en el mismo instante en
/// que alguien escucha, así que no se pierde nada.
Stream<T> currentThenChanges<T>({
  required T Function() current,
  required Stream<T> changes,
}) {
  late final StreamController<T> controller;
  StreamSubscription<T>? subscription;

  controller = StreamController<T>(
    onListen: () {
      // 1. Se anota en la fila el valor actual...
      controller.add(current());
      // 2. ...y de inmediato (sin esperar) se escuchan los cambios.
      subscription = changes.listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
      );
    },
    // Cuando el oyente se va, se deja de escuchar el origen.
    onCancel: () => subscription?.cancel(),
  );

  return controller.stream;
}
