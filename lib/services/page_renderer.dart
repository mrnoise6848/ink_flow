import 'dart:math';
import 'dart:ui' as ui;

import 'package:pdfrx/pdfrx.dart';

import '../data/local_store.dart';
import '../domain/models.dart';

class PageRenderer {
  PageRenderer(this.store);
  final LocalStore store;
  Future<ui.Image?> background(InkPage page, {int maxDimension = 1800}) async {
    if (page.background == null) return null;
    final file = store.file(page.background!);
    if (page.pdfPage != null) {
      await pdfrxFlutterInitialize();
      final document = await PdfDocument.openFile(file.path);
      try {
        if (page.pdfPage! < 1 || page.pdfPage! > document.pages.length)
          throw const FormatException('PDF page missing');
        final source = document.pages[page.pdfPage! - 1];
        final scale = maxDimension / max(source.width, source.height);
        final raster = await source.render(
          fullWidth: source.width * scale,
          fullHeight: source.height * scale,
        );
        if (raster == null) throw StateError('Could not render PDF page');
        try {
          return await raster.createImage();
        } finally {
          raster.dispose();
        }
      } finally {
        await document.dispose();
      }
    }
    final buffer = await ui.ImmutableBuffer.fromFilePath(file.path);
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    ui.Codec? codec;
    try {
      final scale = min(
        1.0,
        maxDimension / max(descriptor.width, descriptor.height),
      );
      codec = await descriptor.instantiateCodec(
        targetWidth: max(1, (descriptor.width * scale).round()),
        targetHeight: max(1, (descriptor.height * scale).round()),
      );
      return (await codec.getNextFrame()).image;
    } finally {
      codec?.dispose();
      descriptor.dispose();
      buffer.dispose();
    }
  }
}
