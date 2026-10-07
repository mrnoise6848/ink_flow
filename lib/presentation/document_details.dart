import 'package:flutter/material.dart';

import '../data/library.dart';
import '../domain/models.dart';
import 'library_screen.dart';

Future<void> documentDetails(
  BuildContext context,
  Library library,
  InkDocument document,
) async {
  final action = await showModalBottomSheet<String>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(document.title),
            subtitle: Text(
              document.tags.isEmpty ? 'No tags' : document.tags.join(', '),
            ),
          ),
          for (final entry in {
            'rename': 'Rename document',
            'tags': 'Edit tags',
            'move': 'Move to notebook',
            'delete': 'Delete document',
          }.entries)
            ListTile(
              title: Text(entry.value),
              onTap: () => Navigator.pop(context, entry.key),
            ),
        ],
      ),
    ),
  );
  if (!context.mounted || action == null) return;
  if (action == 'rename') {
    final title = await askText(context, 'Rename document', document.title);
    if (title != null) {
      document.title = title;
      library.changed(document);
    }
  } else if (action == 'tags') {
    final tags = await askText(
      context,
      'Tags separated by commas (enter - to clear)',
      document.tags.join(', '),
    );
    if (tags != null) {
      document.tags = tags == '-'
          ? []
          : tags
                .split(',')
                .map((v) => v.trim())
                .where((v) => v.isNotEmpty)
                .toSet()
                .take(20)
                .toList();
      library.changed(document);
    }
  } else if (action == 'move') {
    final id = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Move to notebook'),
        children: library.notebooks
            .map(
              (n) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, n.id),
                child: Text(n.title),
              ),
            )
            .toList(),
      ),
    );
    if (id != null) {
      document.notebookId = id;
      library.changed(document);
    }
  } else if (action == 'delete') {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete document?'),
        content: const Text(
          'The document will disappear from your library. Export it first if you need a copy.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      library.documents.remove(document);
      await library.save();
    }
  }
}
