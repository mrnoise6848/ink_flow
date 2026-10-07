import 'dart:ui' as ui;
import 'dart:math';

import 'package:file_selector/file_selector.dart';
import 'package:pdfrx/pdfrx.dart';

import '../data/library.dart';
import '../domain/models.dart';

class FileImporter {
  FileImporter(this.library);
  final Library library;
  Future<InkDocument?> importImage(String notebookId) async {
    final selected = await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(
          label: 'Images',
          extensions: ['png', 'jpg', 'jpeg', 'webp'],
          mimeTypes: ['image/png', 'image/jpeg', 'image/webp'],
          uniformTypeIdentifiers: [
            'public.png',
            'public.jpeg',
            'org.webmproject.webp',
          ],
        ),
      ],
    );
    if (selected == null) return null;
    final extension = selected.name.split('.').last.toLowerCase();
    if (!['png', 'jpg', 'jpeg', 'webp'].contains(extension))
      throw const FormatException('Unsupported image format');
    final asset = 'assets/${newId()}.$extension';
    final file = library.store.file(asset);
    try {
      final sink = file.openWrite();
      try {
        await sink.addStream(selected.openRead());
      } finally {
        await sink.close();
      }
      final buffer = await ui.ImmutableBuffer.fromFilePath(file.path);
      ui.ImageDescriptor? descriptor;
      late double width, height;
      try {
        descriptor = await ui.ImageDescriptor.encoded(buffer);
        final scale = 842 / max(descriptor.width, descriptor.height);
        width = descriptor.width * scale;
        height = descriptor.height * scale;
      } finally {
        descriptor?.dispose();
        buffer.dispose();
      }
      final page = InkPage(
        id: newId(),
        width: width,
        height: height,
        background: asset,
      );
      await library.store.savePage(page);
      final document = InkDocument(
        id: newId(),
        title: selected.name,
        notebookId: notebookId,
        pages: [page.id],
      );
      library.documents.add(document);
      await library.save();
      return document;
    } catch (_) {
      if (await file.exists()) await file.delete();
      rethrow;
    }
  }

  Future<InkDocument?> importPdf(String notebookId) async {
    final selected = await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(
          label: 'PDF',
          extensions: ['pdf'],
          mimeTypes: ['application/pdf'],
          uniformTypeIdentifiers: ['com.adobe.pdf'],
        ),
      ],
    );
    if (selected == null) return null;
    final asset = 'assets/${newId()}.pdf';
    final file = library.store.file(asset);
    PdfDocument? pdf;
    final createdPages = <String>[];
    try {
      final sink = file.openWrite();
      try {
        await sink.addStream(selected.openRead());
      } finally {
        await sink.close();
      }
      await pdfrxFlutterInitialize();
      pdf = await PdfDocument.openFile(file.path);
      if (pdf.pages.isEmpty)
        throw const FormatException('PDF contains no pages');
      final document = InkDocument(
        id: newId(),
        title: selected.name,
        notebookId: notebookId,
      );
      for (final source in pdf.pages) {
        final page = InkPage(
          id: newId(),
          width: source.width,
          height: source.height,
          background: asset,
          pdfPage: source.pageNumber,
        );
        await library.store.savePage(page);
        createdPages.add(page.id);
        document.pages.add(page.id);
      }
      library.documents.add(document);
      await library.save();
      return document;
    } catch (_) {
      if (await file.exists()) await file.delete();
      for (final id in createdPages) {
        final page = library.store.file('pages/$id.json');
        if (await page.exists()) await page.delete();
      }
      rethrow;
    } finally {
      await pdf?.dispose();
    }
  }
}
