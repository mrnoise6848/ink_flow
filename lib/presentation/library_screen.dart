import 'package:flutter/material.dart';

import '../data/library.dart';
import '../domain/models.dart';
import '../domain/search.dart';
import 'editor_screen.dart';
import 'document_details.dart';
import '../services/importer.dart';

Future<String?> askText(
  BuildContext context,
  String title, [
  String initial = '',
  bool allowEmpty = false,
]) async {
  final controller = TextEditingController(text: initial);
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: 120,
        onSubmitted: (v) => Navigator.pop(context, v.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    ),
  );
  // Dialog's route can still animate after pop; dispose after the frame settles.
  Future<void>.delayed(const Duration(seconds: 1), controller.dispose);
  return result == null || (!allowEmpty && result.isEmpty) ? null : result;
}

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key, required this.library});
  final Library library;
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String query = '';
  String? notebook;
  bool favorites = false;
  bool importing = false;
  Future<void> importFile({bool image = false}) async {
    if (importing) return;
    setState(() => importing = true);
    try {
      if (library.notebooks.isEmpty) library.addNotebook('My notebook');
      final importer = FileImporter(library);
      final target = notebook ?? library.notebooks.first.id;
      final d = image
          ? await importer.importImage(target)
          : await importer.importPdf(target);
      if (mounted && d != null) await openDocument(d);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    } finally {
      if (mounted) setState(() => importing = false);
    }
  }

  Library get library => widget.library;
  Future<void> openDocument(InkDocument d) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => EditorScreen(library: library, document: d),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> createNote() async {
    if (library.notebooks.isEmpty) {
      library.addNotebook('My notebook');
    }
    final title = await askText(context, 'New note', 'Untitled note');
    if (title == null) return;
    try {
      final d = await library.createDocument(
        notebook ?? library.notebooks.first.id,
        title,
      );
      if (mounted) await openDocument(d);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not create note: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: library,
    builder: (context, _) {
      final docs =
          library.documents
              .where(
                (d) =>
                    (notebook == null || d.notebookId == notebook) &&
                    (!favorites || d.favorite) &&
                    DocumentSearch().matches(d, library.notebooks, query),
              )
              .toList()
            ..sort((a, b) => b.modified.compareTo(a.modified));
      return Scaffold(
        appBar: AppBar(
          title: const Text('InkFlow'),
          actions: [
            IconButton(
              tooltip: 'Open-source licenses',
              icon: const Icon(Icons.info_outline),
              onPressed: () =>
                  showLicensePage(context: context, applicationName: 'InkFlow'),
            ),
            IconButton(
              tooltip: 'Import image',
              onPressed: importing ? null : () => importFile(image: true),
              icon: const Icon(Icons.image_outlined),
            ),
            IconButton(
              tooltip: 'Import PDF',
              onPressed: importing ? null : importFile,
              icon: const Icon(Icons.file_open_outlined),
            ),
            IconButton(
              tooltip: 'Privacy',
              icon: const Icon(Icons.shield_outlined),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => const AlertDialog(
                  title: Text('Your notes stay here'),
                  content: Text(
                    'InkFlow stores notes and imported files on this device. No account, analytics or document uploads. Sharing sends only the export you select to your chosen app.',
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: createNote,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('New note'),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (library.error != null)
                    MaterialBanner(
                      content: Text(library.error!),
                      actions: [
                        TextButton(
                          onPressed: library.save,
                          child: const Text('Retry save'),
                        ),
                      ],
                    ),
                  if (library.recoveryWarning != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(library.recoveryWarning!),
                    ),
                  if (importing) const LinearProgressIndicator(),
                  Text(
                    'Write. Annotate. Organize.',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search titles, notebooks, tags or dates',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => query = v),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('Recent'),
                          selected: notebook == null && !favorites,
                          onSelected: (_) => setState(() {
                            notebook = null;
                            favorites = false;
                          }),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Favorites'),
                          selected: favorites,
                          onSelected: (v) => setState(() => favorites = v),
                        ),
                        for (final n in library.notebooks)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: InputChip(
                              label: Text(n.title),
                              selected: notebook == n.id,
                              onPressed: () => setState(
                                () => notebook = notebook == n.id ? null : n.id,
                              ),
                              onDeleted: () async {
                                final title = await askText(
                                  context,
                                  'Rename notebook',
                                  n.title,
                                );
                                if (title != null) {
                                  n.title = title;
                                  await library.save();
                                }
                              },
                              deleteIcon: const Icon(Icons.edit, size: 16),
                              deleteButtonTooltipMessage: 'Rename notebook',
                            ),
                          ),
                        const SizedBox(width: 8),
                        ActionChip(
                          label: const Text('New notebook'),
                          avatar: const Icon(Icons.add),
                          onPressed: () async {
                            final title = await askText(
                              context,
                              'New notebook',
                            );
                            if (title != null) library.addNotebook(title);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: docs.isEmpty
                        ? const Center(
                            child: Text(
                              'A fresh page for your next idea.\nCreate a note to begin.',
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: docs.length,
                            itemBuilder: (context, i) {
                              final d = docs[i];
                              return Card(
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.description_outlined,
                                  ),
                                  title: Text(
                                    d.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    '${d.pages.length} pages • ${d.modified.toLocal().toString().substring(0, 16)}${d.tags.isEmpty ? '' : '\n${d.tags.join(' • ')}'}',
                                  ),
                                  onTap: () => openDocument(d),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: 'Document options',
                                        icon: const Icon(Icons.more_vert),
                                        onPressed: () => documentDetails(
                                          context,
                                          library,
                                          d,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: d.favorite
                                            ? 'Remove favorite'
                                            : 'Favorite',
                                        icon: Icon(
                                          d.favorite
                                              ? Icons.star
                                              : Icons.star_border,
                                        ),
                                        onPressed: () {
                                          d.favorite = !d.favorite;
                                          library.changed(d);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
