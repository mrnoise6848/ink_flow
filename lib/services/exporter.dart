import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/local_store.dart';
import '../domain/models.dart';
import '../presentation/ink_canvas.dart';
import 'page_renderer.dart';

class FileExporter {
  FileExporter(this.store);
  final LocalStore store;
  Future<Uint8List> pagePng(InkPage page, {int maxDimension = 1800}) async {
    final background = await PageRenderer(store)
        .background(page, maxDimension: maxDimension);
    final scale = maxDimension / max(page.width, page.height);
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder)..scale(scale);
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, page.width, page.height),
      ui.Paint()..color = const ui.Color(0xffffffff),
    );
    if (background != null)
      canvas.drawImageRect(
        background,
        ui.Rect.fromLTWH(
          0,
          0,
          background.width.toDouble(),
          background.height.toDouble(),
        ),
        ui.Rect.fromLTWH(0, 0, page.width, page.height),
        ui.Paint(),
      );
    paintStrokes(canvas, page.strokes);
    final picture = recorder.endRecording();
    ui.Image? image;
    try {
      image = await picture.toImage(
        max(1, (page.width * scale).round()),
        max(1, (page.height * scale).round()),
      );
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) throw StateError('Image export failed');
      return bytes.buffer.asUint8List();
    } finally {
      image?.dispose();
      picture.dispose();
      background?.dispose();
    }
  }

  Future<File> exportImage(InkPage page) async {
    final file = store.file('exports/${newId()}.png');
    await file.writeAsBytes(await pagePng(page), flush: true);
    return file;
  }

  Future<File> exportPdf(
    InkDocument document, {
    void Function(int, int)? progress,
    bool Function()? cancelled,
  }) async {
    final pdf = pw.Document(title: document.title, creator: 'InkFlow');
    for (var i = 0; i < document.pages.length; i++) {
      if (cancelled?.call() == true) throw const ExportCancelled();
      final page = await store.loadPage(document.pages[i]);
      final png = await pagePng(page);
      final image = pw.MemoryImage(png);
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(page.width, page.height, marginAll: 0),
          build: (_) => pw.Image(image, fit: pw.BoxFit.fill),
        ),
      );
      progress?.call(i + 1, document.pages.length);
      await Future<void>.delayed(Duration.zero);
    }
    final output = store.file('exports/${newId()}.pdf');
    await output.writeAsBytes(
      await pdf.save(enableEventLoopBalancing: true),
      flush: true,
    );
    return output;
  }
}

class ExportCancelled implements Exception {
  const ExportCancelled();
}
