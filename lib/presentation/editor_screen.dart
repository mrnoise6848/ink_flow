import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/library.dart';
import '../domain/models.dart';
import 'ink_canvas.dart';
import 'page_viewport.dart';
import '../services/page_renderer.dart';
import '../services/exporter.dart';
import '../services/export_delivery.dart';
import 'library_screen.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({
    super.key,
    required this.library,
    required this.document,
  });
  final Library library;
  final InkDocument document;
  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen>
    with WidgetsBindingObserver {
  late DrawingController drawing = DrawingController(InkPage(id: newId()));
  int index = 0;
  bool loading = true, dirty = false;
  String? error;
  ui.Image? background;
  Timer? timer;
  Future<void>? saving;
  bool exporting = false, cancelExport = false;
  int exportedPages = 0;
  Future<void> export(String format) async {
    if (exporting || loading || error != null) return;
    await persist();
    if (dirty || !mounted) return;
    setState(() {
      exporting = true;
      cancelExport = false;
      exportedPages = 0;
    });
    try {
      final exporter = FileExporter(widget.library.store);
      final file = format.endsWith('png')
          ? await exporter.exportImage(drawing.page)
          : await exporter.exportPdf(
              widget.document,
              cancelled: () => cancelExport,
              progress: (done, total) {
                if (mounted) setState(() => exportedPages = done);
              },
            );
      if (!mounted || cancelExport) return;
      final box = context.findRenderObject() as RenderBox?;
      final anchor = box == null
          ? const Rect.fromLTWH(0, 0, 1, 1)
          : box.localToGlobal(Offset.zero) & box.size;
      final delivery = ExportDelivery();
      if (format.startsWith('share')) {
        await delivery.share(file, widget.document.title, anchor);
      } else {
        await delivery.save(file, widget.document.title, anchor);
      }
    } on ExportCancelled {
      /* User cancelled between pages. */
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Export failed: $e')));
    } finally {
      if (mounted) setState(() => exporting = false);
    }
  }

  Future<void> addPage({bool duplicate = false}) async {
    await persist();
    if (dirty || !mounted) return;
    final source = drawing.page;
    final page = duplicate
        ? InkPage(
            id: newId(),
            width: source.width,
            height: source.height,
            background: source.background,
            pdfPage: source.pdfPage,
            strokes: List.of(source.strokes),
          )
        : InkPage(id: newId());
    try {
      await widget.library.store.savePage(page);
      widget.document.pages.insert(index + 1, page.id);
      await widget.library.save();
      await loadPage(index + 1);
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    }
  }

  Future<void> pageAction(String action) async {
    if (loading || drawing.pointer != null) return;
    if (action == 'add' || action == 'duplicate') {
      await addPage(duplicate: action == 'duplicate');
      return;
    }
    if (action == 'delete') {
      if (widget.document.pages.length == 1) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete this page?'),
          content: const Text('This removes the page from this document.'),
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
      if (confirmed != true) return;
    }
    await persist();
    if (dirty || !mounted) return;
    final pages = widget.document.pages;
    if (action == 'delete') {
      pages.removeAt(index);
      index = index.clamp(0, pages.length - 1);
    } else {
      final target = action == 'earlier' ? index - 1 : index + 1;
      if (target < 0 || target >= pages.length) return;
      final id = pages.removeAt(index);
      pages.insert(target, id);
      index = target;
    }
    await widget.library.save();
    await loadPage(index);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadPage(0);
  }

  Future<void> persist() async {
    timer?.cancel();
    if (saving != null) await saving;
    if (!dirty) return;
    dirty = false;
    final page = drawing.page;
    saving = widget.library.savePage(widget.document, page);
    try {
      await saving;
      if (mounted) setState(() => error = null);
    } catch (e) {
      dirty = true;
      if (mounted) setState(() => error = '$e');
    } finally {
      saving = null;
    }
  }

  Future<void> loadPage(int value) async {
    await persist();
    if (dirty) return;
    if (!mounted) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final page = await widget.library.store.loadPage(
        widget.document.pages[value],
      );
      final image = await PageRenderer(widget.library.store).background(page);
      if (!mounted) {
        image?.dispose();
        return;
      }
      background?.dispose();
      background = image;
      drawing.dispose();
      drawing = DrawingController(page)
        ..onChanged = () {
          setState(() => dirty = true);
          timer?.cancel();
          timer = Timer(const Duration(milliseconds: 500), persist);
        };
      index = value;
    } catch (e) {
      error =
          'Could not load this page. The rest of the document is available. $e';
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      if (drawing.pointer != null) {
        drawing.end(PointerUpEvent(pointer: drawing.pointer!));
      }
      persist();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();
    drawing.dispose();
    background?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !dirty && saving == null && !exporting,
    onPopInvokedWithResult: (didPop, result) async {
      if (didPop || exporting) return;
      await persist();
      if (context.mounted && !dirty) Navigator.pop(context);
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.document.title),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Export',
            enabled: !loading && !exporting && error == null,
            onSelected: export,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'pdf',
                child: Text('Export document as PDF'),
              ),
              PopupMenuItem(value: 'png', child: Text('Export page as PNG')),
              PopupMenuItem(
                value: 'share-pdf',
                child: Text('Share document PDF'),
              ),
              PopupMenuItem(value: 'share-png', child: Text('Share page PNG')),
            ],
            icon: const Icon(Icons.ios_share),
          ),
          PopupMenuButton<String>(
            tooltip: 'Page actions',
            onSelected: pageAction,
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'add', child: Text('Add page')),
              const PopupMenuItem(
                value: 'duplicate',
                child: Text('Duplicate page'),
              ),
              const PopupMenuItem(
                value: 'earlier',
                child: Text('Move page earlier'),
              ),
              const PopupMenuItem(
                value: 'later',
                child: Text('Move page later'),
              ),
              PopupMenuItem(
                value: 'delete',
                enabled: widget.document.pages.length > 1,
                child: const Text('Delete page'),
              ),
            ],
          ),
          IconButton(
            tooltip: 'Rename document',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final title = await askText(
                context,
                'Rename document',
                widget.document.title,
              );
              if (title != null) {
                widget.document.title = title;
                widget.library.changed(widget.document);
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (exporting)
            ListTile(
              leading: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(),
              ),
              title: Text(
                'Exporting $exportedPages / ${widget.document.pages.length}',
              ),
              trailing: TextButton(
                onPressed: () => cancelExport = true,
                child: const Text('Cancel'),
              ),
            ),
          if (error != null)
            MaterialBanner(
              content: Text(error!),
              actions: [
                TextButton(
                  onPressed: () async {
                    await persist();
                    if (!dirty) await loadPage(index);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          Material(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Undo',
                    icon: const Icon(Icons.undo),
                    onPressed: drawing.undo,
                  ),
                  IconButton(
                    tooltip: 'Redo',
                    icon: const Icon(Icons.redo),
                    onPressed: drawing.redo,
                  ),
                  IconButton(
                    tooltip: 'Pen',
                    isSelected:
                        !drawing.eraser && !drawing.pan && !drawing.highlight,
                    icon: const Icon(Icons.edit),
                    onPressed: () => setState(() {
                      drawing.eraser = false;
                      drawing.pan = false;
                      drawing.highlight = false;
                    }),
                  ),
                  IconButton(
                    tooltip: 'Highlighter',
                    isSelected: drawing.highlight && !drawing.pan,
                    icon: const Icon(Icons.brush_outlined),
                    onPressed: () => setState(() {
                      drawing.highlight = true;
                      drawing.eraser = false;
                      drawing.pan = false;
                    }),
                  ),
                  IconButton(
                    tooltip: 'Eraser',
                    isSelected: drawing.eraser,
                    icon: const Icon(Icons.auto_fix_normal),
                    onPressed: () => setState(() {
                      drawing.eraser = true;
                      drawing.pan = false;
                    }),
                  ),
                  IconButton(
                    tooltip: 'Pan and zoom',
                    isSelected: drawing.pan,
                    icon: const Icon(Icons.pan_tool_outlined),
                    onPressed: () => setState(() => drawing.pan = !drawing.pan),
                  ),
                  for (final color in [
                    0xff202a35,
                    0xff256d60,
                    0xffc0392b,
                    0xff265cc5,
                    0xffffb300,
                  ])
                    IconButton(
                      tooltip:
                          'Ink color ${Color(color).toARGB32().toRadixString(16)}',
                      icon: Icon(Icons.circle, color: Color(color)),
                      onPressed: () => setState(() => drawing.color = color),
                    ),
                  SizedBox(
                    width: 140,
                    child: Slider(
                      label: 'Stroke width ${drawing.width.round()}',
                      value: drawing.width,
                      min: 1,
                      max: 20,
                      onChanged: (v) => setState(() => drawing.width = v),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Clear page',
                    icon: const Icon(Icons.delete_sweep_outlined),
                    onPressed: drawing.clear,
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: 'Previous page',
                onPressed: index > 0 && !loading
                    ? () => loadPage(index - 1)
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Text('Page ${index + 1} / ${widget.document.pages.length}'),
              IconButton(
                tooltip: 'Next page',
                onPressed: index + 1 < widget.document.pages.length && !loading
                    ? () => loadPage(index + 1)
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                ? const Center(child: Text('Page unavailable'))
                : PageViewport(
                    key: ValueKey(drawing.page.id),
                    pageSize: Size(drawing.page.width, drawing.page.height),
                    pan: drawing.pan,
                    child: AbsorbPointer(
                      absorbing: exporting,
                      child: InkCanvas(
                        controller: drawing,
                        background: background,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    ),
  );
}
