import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// Abre la base de datos en la carpeta de documentos de la app
// Los datos se guardan en un archivo y sobreviven al cierre de la app

QueryExecutor openConnection() {
  return LazyDatabase(() async {
    // Carpeta privada de la app en el telefono
    final carpeta = await getApplicationDocumentsDirectory();
    final archivo = File(p.join(carpeta.path, 'pokedex.sqlite'));

    // Se ejecutan las consultas en un isolate separado, para no bloquear la interfaz
    return NativeDatabase.createInBackground(archivo);
  });
}
