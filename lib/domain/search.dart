import 'models.dart';

/// Local metadata index; a future recognition provider may add indexed text
/// without changing the page representation or requiring a cloud service.
class DocumentSearch {
  bool matches(
    InkDocument document,
    Iterable<Notebook> notebooks,
    String query,
  ) {
    final notebook = notebooks
        .where((n) => n.id == document.notebookId)
        .map((n) => n.title)
        .join(' ');
    final haystack =
        '${document.title} $notebook ${document.tags.join(' ')} ${document.created.toIso8601String()} ${document.modified.toIso8601String()} ${document.pages.length} pages'
            .toLowerCase();
    return query
        .toLowerCase()
        .trim()
        .split(RegExp(r'\s+'))
        .every(haystack.contains);
  }
}
