import 'package:flutter/foundation.dart';
import '../domain/models.dart';

class Library extends ChangeNotifier {
  final List<Notebook> notebooks = [];
  final List<InkDocument> documents = [];
  String? error;
  Future<void> initialize() async {}
  Future<void> save() async { notifyListeners(); }
  Notebook addNotebook(String title) {
    final n = Notebook(id: newId(), title: title.trim());
    notebooks.add(n); save(); return n;
  }
  Future<InkDocument> createDocument(String notebookId, String title) async {
    final d = InkDocument(id: newId(), title: title, notebookId: notebookId);
    documents.add(d); await save(); return d;
  }
  void changed(InkDocument d) { d.modified = DateTime.now(); save(); }
}
