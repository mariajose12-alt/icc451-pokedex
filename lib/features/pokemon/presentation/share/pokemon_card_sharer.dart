import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

/// Convierte la carta en PNG y la comparte. Es una interfaz para que las
/// pruebas usen un falso en vez de abrir la hoja de compartir del sistema.
abstract class PokemonCardSharer {
  Future<void> shareCard({
    required GlobalKey boundaryKey,
    required String fileName,
    required String text,
  });
}

/// Implementación real: captura el RepaintBoundary a 3× y comparte el PNG.
class ImagePokemonCardSharer implements PokemonCardSharer {
  const ImagePokemonCardSharer();

  // 378×528 a 3× da 1134×1584 px: nítida al guardarla o enviarla.
  static const _pixelRatio = 3.0;

  @override
  Future<void> shareCard({
    required GlobalKey boundaryKey,
    required String fileName,
    required String text,
  }) async {
    final boundary =
        boundaryKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) {
      throw StateError('La carta aún no está en pantalla.');
    }

    final image = await boundary.toImage(pixelRatio: _pixelRatio);
    final ByteData? bytes;
    try {
      bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    } finally {
      image.dispose();
    }
    if (bytes == null) {
      throw StateError('No se pudo codificar la imagen.');
    }

    // Archivo temporal: el sistema lo lee al compartir.
    final file = File('${Directory.systemTemp.path}/$fileName');
    await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        text: text,
      ),
    );
  }
}
