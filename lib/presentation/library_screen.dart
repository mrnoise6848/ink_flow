import 'package:flutter/material.dart';
import '../data/library.dart';
import '../domain/models.dart';
import 'editor_screen.dart';

Future<String?> askText(BuildContext context, String title, [String initial = '']) async {
  final controller = TextEditingController(text: initial);
  final result = await showDialog<String>(context: context, builder: (context) => AlertDialog(title: Text(title), content: TextField(controller: controller, autofocus: true, maxLength: 120, onSubmitted: (v) => Navigator.pop(context, v.trim())), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save'))]));
  // Dialog's route can still animate after pop; dispose after the frame settles.
  Future<void>.delayed(const Duration(seconds: 1), controller.dispose);
  return result == null || result.isEmpty ? null : result;
}

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key, required this.library});
  final Library library;
  @override State<LibraryScreen> createState() => _LibraryScreenState();
}
class _LibraryScreenState extends State<LibraryScreen> {
  String query = '';
  String? notebook;
  bool favorites = false;
  Library get library => widget.library;
  Future<void> openDocument(InkDocument d) async {
    await Navigator.push<void>(context, MaterialPageRoute(builder: (_) => EditorScreen(library: library, document: d)));
    if (mounted) setState(() {});
  }
  Future<void> createNote() async {
    if (library.notebooks.isEmpty) { library.addNotebook('My notebook'); }
    final title = await askText(context, 'New note', 'Untitled note');
    if (title == null) return;
    final d = await library.createDocument(notebook ?? library.notebooks.first.id, title);
    if (mounted) await openDocument(d);
  }
  @override Widget build(BuildContext context) => ListenableBuilder(listenable: library, builder: (context, _) {
    final docs = library.documents.where((d) => (notebook == null || d.notebookId == notebook) && (!favorites || d.favorite) && d.title.toLowerCase().contains(query.toLowerCase())).toList()..sort((a, b) => b.modified.compareTo(a.modified));
    return Scaffold(appBar: AppBar(title: const Text('InkFlow'), actions: [IconButton(tooltip: 'Privacy', icon: const Icon(Icons.shield_outlined), onPressed: () => showDialog<void>(context: context, builder: (context) => const AlertDialog(title: Text('Your notes stay here'), content: Text('InkFlow stores notes and imported files on this device. No account, analytics or document uploads. Sharing sends only the export you select to your chosen app.'))))]), floatingActionButton: FloatingActionButton.extended(onPressed: createNote, icon: const Icon(Icons.edit_outlined), label: const Text('New note')), body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1100), child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Write. Annotate. Organize.', style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 16), TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search your library', border: OutlineInputBorder()), onChanged: (v) => setState(() => query = v)), const SizedBox(height: 12), SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [FilterChip(label: const Text('Recent'), selected: notebook == null && !favorites, onSelected: (_) => setState(() { notebook = null; favorites = false; })), const SizedBox(width: 8), FilterChip(label: const Text('Favorites'), selected: favorites, onSelected: (v) => setState(() => favorites = v)), for (final n in library.notebooks) Padding(padding: const EdgeInsets.only(left: 8), child: InputChip(label: Text(n.title), selected: notebook == n.id, onPressed: () => setState(() => notebook = notebook == n.id ? null : n.id), onDeleted: () async { final title = await askText(context, 'Rename notebook', n.title); if (title != null) { n.title = title; await library.save(); } }, deleteIcon: const Icon(Icons.edit, size: 16), deleteButtonTooltipMessage: 'Rename notebook')), const SizedBox(width: 8), ActionChip(label: const Text('New notebook'), avatar: const Icon(Icons.add), onPressed: () async { final title = await askText(context, 'New notebook'); if (title != null) library.addNotebook(title); })])), const SizedBox(height: 16), Expanded(child: docs.isEmpty ? const Center(child: Text('A fresh page for your next idea.\nCreate a note to begin.', textAlign: TextAlign.center)) : ListView.builder(padding: const EdgeInsets.only(bottom: 80), itemCount: docs.length, itemBuilder: (context, i) { final d = docs[i]; return Card(child: ListTile(leading: const Icon(Icons.description_outlined), title: Text(d.title), subtitle: Text('${d.pages.length} pages • ${d.modified.toLocal().toString().substring(0, 16)}'), onTap: () => openDocument(d), trailing: IconButton(tooltip: d.favorite ? 'Remove favorite' : 'Favorite', icon: Icon(d.favorite ? Icons.star : Icons.star_border), onPressed: () { d.favorite = !d.favorite; library.changed(d); }))); }))])))));
  });
}
