import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:pdfrx/pdfrx.dart';

import '../data/library.dart';
import '../domain/models.dart';

class FileImporter {
  FileImporter(this.library);
  final Library library;
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
