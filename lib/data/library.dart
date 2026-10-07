import 'package:flutter/foundation.dart';

import '../domain/models.dart';
import 'local_store.dart';

class Library extends ChangeNotifier {
  final List<Notebook> notebooks = [];
  final List<InkDocument> documents = [];
  String? error;
  final store = LocalStore();
  Future<void> initialize() async {
    await store.initialize();
    if (!await store.file('library.json').exists() &&
        !await store.file('library.json.bak').exists())
      return;
    final j = await store.read('library.json') as Map<String, dynamic>;
    if (j['version'] != 1)
      throw const FormatException('Unsupported library version');
    for (final n in j['notebooks'] as List) {
      notebooks.add(Notebook.fromJson(n as Map<String, dynamic>));
    }
    for (final d in j['documents'] as List) {
      documents.add(InkDocument.fromJson(d as Map<String, dynamic>));
    }
  }

  Future<void> save() async {
    notifyListeners();
    try {
      await store.write('library.json', {
        'version': 1,
        'notebooks': notebooks.map((n) => n.toJson()).toList(),
        'documents': documents.map((d) => d.toJson()).toList(),
      });
      error = null;
    } catch (e) {
      error = 'Could not save library. Free storage and retry. $e';
    }
    notifyListeners();
  }

  Future<void> savePage(InkDocument document, InkPage page) async {
    try {
      await store.savePage(page);
      error = null;
      changed(document);
    } catch (e) {
      error = 'Could not save page. Keep the editor open and retry. $e';
      notifyListeners();
      rethrow;
    }
  }

  Notebook addNotebook(String title) {
    final n = Notebook(id: newId(), title: title.trim());
    notebooks.add(n);
    save();
    return n;
  }

  Future<InkDocument> createDocument(String notebookId, String title) async {
    final d = InkDocument(id: newId(), title: title, notebookId: notebookId);
    final page = InkPage(id: newId());
    await store.savePage(page);
    d.pages.add(page.id);
    documents.add(d);
    await save();
    return d;
  }

  void changed(InkDocument d) {
    d.modified = DateTime.now();
    save();
  }
}
