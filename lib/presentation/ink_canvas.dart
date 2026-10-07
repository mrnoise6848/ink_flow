import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../domain/models.dart';

class DrawingController extends ChangeNotifier {
  DrawingController(this.page);
  final InkPage page;
  InkStroke? active;
  int color = 0xff202a35;
  double width = 3;
  bool eraser = false, highlight = false, pan = false;
  VoidCallback? onChanged;
  int revision = 0;
  final status = ValueNotifier<int>(0);
  ui.Picture? _picture;
  int _pictureRevision = -1;
  ui.Picture get picture {
    if (_picture == null || _pictureRevision != revision) {
      _picture?.dispose();
      final recorder = ui.PictureRecorder();
      paintStrokes(Canvas(recorder), page.strokes);
      _picture = recorder.endRecording();
      _pictureRevision = revision;
    }
    return _picture!;
  }

  @override
  void dispose() {
    _picture?.dispose();
    status.dispose();
    super.dispose();
  }

  void changed() {
    revision++;
    status.value++;
    onChanged?.call();
    notifyListeners();
  }

  final List<List<InkStroke>> _undo = [], _redo = [];
  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;
  void checkpoint() {
    _undo.add(List.of(page.strokes));
    if (_undo.length > 80) _undo.removeAt(0);
    _redo.clear();
  }

  void undo() {
    if (!canUndo || pointer != null) return;
    _redo.add(List.of(page.strokes));
    page.strokes
      ..clear()
      ..addAll(_undo.removeLast());
    changed();
  }

  void redo() {
    if (!canRedo || pointer != null) return;
    _undo.add(List.of(page.strokes));
    page.strokes
      ..clear()
      ..addAll(_redo.removeLast());
    changed();
  }

  List<InkStroke>? _beforeGesture;
  void commitGesture() {
    final before = _beforeGesture;
    if (before != null && !listEquals(before, page.strokes)) {
      _undo.add(before);
      if (_undo.length > 80) _undo.removeAt(0);
      _redo.clear();
    }
    _beforeGesture = null;
  }

  int? pointer;
  bool pressureAvailable = false;
  double pressure(PointerEvent e) {
    final stylus =
        e.kind == PointerDeviceKind.stylus ||
        e.kind == PointerDeviceKind.invertedStylus;
    final supported = stylus && e.pressureMax > e.pressureMin;
    pressureAvailable = supported;
    if (!supported) return 1;
    return ((e.pressure - e.pressureMin) / (e.pressureMax - e.pressureMin))
        .clamp(0.05, 1);
  }

  void begin(PointerDownEvent e) {
    if (pan || pointer != null) return;
    pointer = e.pointer;
    _beforeGesture = List.of(page.strokes);
    if (eraser) {
      erase(e.localPosition);
      return;
    }
    active = InkStroke(
      points: [InkPoint(e.localPosition.dx, e.localPosition.dy, pressure(e))],
      color: color,
      width: width,
      opacity: highlight ? 0.3 : 1,
      device: e.kind.name,
      pressureSupported: pressureAvailable,
    );
    status.value++;
    notifyListeners();
  }

  void move(PointerMoveEvent e) {
    if (e.pointer != pointer) return;
    if (eraser) {
      erase(e.localPosition);
      return;
    }
    final s = active;
    if (s == null) return;
    final p = s.points.last;
    if ((Offset(p.x, p.y) - e.localPosition).distance < 0.5) return;
    s.points.add(InkPoint(e.localPosition.dx, e.localPosition.dy, pressure(e)));
    notifyListeners();
  }

  void end(PointerEvent e) {
    if (e.pointer != pointer) return;
    if (active != null) {
      page.strokes.add(active!);
      active = null;
      commitGesture();
      changed();
    }
    commitGesture();
    pointer = null;
    status.value++;
    notifyListeners();
  }

  void cancel(PointerCancelEvent e) {
    if (pointer == e.pointer) {
      active = null;
      pointer = null;
      if (_beforeGesture != null) {
        page.strokes
          ..clear()
          ..addAll(_beforeGesture!);
        _beforeGesture = null;
        changed();
      }
      notifyListeners();
    }
  }

  bool hitsStroke(InkStroke s, Offset point) {
    final radius = 12 + s.width / 2;
    for (var i = 0; i < s.points.length; i++) {
      final b = Offset(s.points[i].x, s.points[i].y);
      if ((point - b).distance <= radius) return true;
      if (i == 0) continue;
      final a = Offset(s.points[i - 1].x, s.points[i - 1].y), delta = b - a;
      final length = delta.distanceSquared;
      if (length == 0) continue;
      final t =
          (((point.dx - a.dx) * delta.dx + (point.dy - a.dy) * delta.dy) /
                  length)
              .clamp(0.0, 1.0);
      if ((point - (a + delta * t)).distance <= radius) return true;
    }
    return false;
  }

  void erase(Offset point) {
    final old = page.strokes.length;
    page.strokes.removeWhere((s) => hitsStroke(s, point));
    if (page.strokes.length != old) {
      changed();
      notifyListeners();
    }
  }

  void clear() {
    if (page.strokes.isEmpty || pointer != null) return;
    checkpoint();
    page.strokes.clear();
    changed();
  }
}

void paintStrokes(Canvas canvas, Iterable<InkStroke> strokes) {
  for (final stroke in strokes) {
    if (stroke.points.isEmpty) continue;
    final paint = Paint()
      ..color = Color(stroke.color).withValues(alpha: stroke.opacity)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (stroke.points.length == 1) {
      final p = stroke.points.first;
      canvas.drawCircle(Offset(p.x, p.y), stroke.width * p.pressure / 2, paint);
      continue;
    }
    for (var i = 1; i < stroke.points.length; i++) {
      final a = stroke.points[i - 1], b = stroke.points[i];
      paint.strokeWidth = stroke.width * (a.pressure + b.pressure) / 2;
      canvas.drawLine(Offset(a.x, a.y), Offset(b.x, b.y), paint);
    }
  }
}

class InkPainter extends CustomPainter {
  InkPainter(this.controller) : super(repaint: controller);
  final DrawingController controller;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPicture(controller.picture);
    if (controller.active != null) paintStrokes(canvas, [controller.active!]);
  }

  @override
  bool shouldRepaint(InkPainter oldDelegate) =>
      oldDelegate.controller != controller;
}

class InkCanvas extends StatelessWidget {
  const InkCanvas({super.key, required this.controller, this.background});
  final DrawingController controller;
  final ui.Image? background;
  @override
  Widget build(BuildContext context) => Semantics(
    label:
        'Handwriting page, ${controller.page.strokes.length} strokes. Use the toolbar to draw, erase or move the page.',
    child: RepaintBoundary(
      child: SizedBox(
        width: controller.page.width,
        height: controller.page.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: Colors.white,
              child: background == null
                  ? null
                  : RawImage(image: background, fit: BoxFit.fill),
            ),
            Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: controller.begin,
              onPointerMove: controller.move,
              onPointerUp: controller.end,
              onPointerCancel: controller.cancel,
              child: CustomPaint(painter: InkPainter(controller)),
            ),
          ],
        ),
      ),
    ),
  );
}
