import 'package:flutter/material.dart';
import '../data/library.dart';
import '../domain/models.dart';
import 'ink_canvas.dart';
import 'library_screen.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key, required this.library, required this.document});
  final Library library;
  final InkDocument document;
  @override State<EditorScreen> createState() => _EditorScreenState();
}
class _EditorScreenState extends State<EditorScreen> {
  late DrawingController drawing = DrawingController(InkPage(id: newId()));
  final transform = TransformationController();
  @override void dispose() { drawing.dispose(); transform.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(widget.document.title), actions: [IconButton(tooltip: 'Rename document', icon: const Icon(Icons.edit_outlined), onPressed: () async { final title = await askText(context, 'Rename document', widget.document.title); if (title != null) { widget.document.title = title; widget.library.changed(widget.document); setState(() {}); } })]), body: Column(children: [Material(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [IconButton(tooltip: 'Undo', icon: const Icon(Icons.undo), onPressed: drawing.undo), IconButton(tooltip: 'Redo', icon: const Icon(Icons.redo), onPressed: drawing.redo), IconButton(tooltip: 'Pen', isSelected: !drawing.eraser && !drawing.pan && !drawing.highlight, icon: const Icon(Icons.edit), onPressed: () => setState(() { drawing.eraser = false; drawing.pan = false; drawing.highlight = false; })), IconButton(tooltip: 'Eraser', isSelected: drawing.eraser, icon: const Icon(Icons.auto_fix_normal), onPressed: () => setState(() { drawing.eraser = true; drawing.pan = false; })), IconButton(tooltip: 'Pan and zoom', isSelected: drawing.pan, icon: const Icon(Icons.pan_tool_outlined), onPressed: () => setState(() => drawing.pan = !drawing.pan)), for (final color in [0xff202a35, 0xff256d60, 0xffc0392b, 0xff265cc5, 0xffffb300]) IconButton(tooltip: 'Ink color ${Color(color).toARGB32().toRadixString(16)}', icon: Icon(Icons.circle, color: Color(color)), onPressed: () => setState(() => drawing.color = color)), SizedBox(width: 140, child: Slider(label: 'Stroke width ${drawing.width.round()}', value: drawing.width, min: 1, max: 20, onChanged: (v) => setState(() => drawing.width = v))), IconButton(tooltip: 'Clear page', icon: const Icon(Icons.delete_sweep_outlined), onPressed: drawing.clear)]))), Expanded(child: LayoutBuilder(builder: (context, constraints) { final scale = (constraints.maxWidth / drawing.page.width).clamp(0.1, 1.0); return InteractiveViewer(transformationController: transform, constrained: false, minScale: scale * 0.5, maxScale: 5, panEnabled: drawing.pan, scaleEnabled: drawing.pan, child: InkCanvas(controller: drawing)); }))]));
}
