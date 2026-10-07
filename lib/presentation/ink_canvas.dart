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
  int? pointer;
  bool pressureAvailable = false;
  double pressure(PointerEvent e) {
    final stylus = e.kind == PointerDeviceKind.stylus || e.kind == PointerDeviceKind.invertedStylus;
    final supported = stylus && e.pressureMax > e.pressureMin;
    pressureAvailable = supported;
    if (!supported) return 1;
    return ((e.pressure - e.pressureMin) / (e.pressureMax - e.pressureMin)).clamp(0.05, 1);
  }
  void begin(PointerDownEvent e) {
    if (pan || pointer != null) return;
    pointer = e.pointer;
    if (eraser) { erase(e.localPosition); return; }
    active = InkStroke(points: [InkPoint(e.localPosition.dx, e.localPosition.dy, pressure(e))], color: color, width: width, opacity: highlight ? 0.3 : 1, device: e.kind.name, pressureSupported: pressureAvailable);
    notifyListeners();
  }
  void move(PointerMoveEvent e) {
    if (e.pointer != pointer) return;
    if (eraser) { erase(e.localPosition); return; }
    final s = active;
    if (s == null) return;
    final p = s.points.last;
    if ((Offset(p.x, p.y) - e.localPosition).distance < 0.5) return;
    s.points.add(InkPoint(e.localPosition.dx, e.localPosition.dy, pressure(e))); notifyListeners();
  }
  void end(PointerEvent e) {
    if (e.pointer != pointer) return;
    if (active != null) { page.strokes.add(active!); active = null; onChanged?.call(); }
    pointer = null; notifyListeners();
  }
  void cancel(PointerCancelEvent e) { if (pointer == e.pointer) { active = null; pointer = null; notifyListeners(); } }
  void erase(Offset point) {
    final old = page.strokes.length;
    page.strokes.removeWhere((s) => s.points.any((p) => (point - Offset(p.x, p.y)).distance < 12 + s.width / 2));
    if (page.strokes.length != old) { onChanged?.call(); notifyListeners(); }
  }
  void clear() { page.strokes.clear(); onChanged?.call(); notifyListeners(); }
}

void paintStrokes(Canvas canvas, Iterable<InkStroke> strokes) {
  for (final stroke in strokes) {
    if (stroke.points.isEmpty) continue;
    final paint = Paint()..color = Color(stroke.color).withValues(alpha: stroke.opacity)..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    if (stroke.points.length == 1) {
      final p = stroke.points.first;
      canvas.drawCircle(Offset(p.x, p.y), stroke.width * p.pressure / 2, paint); continue;
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
  @override void paint(Canvas canvas, Size size) { paintStrokes(canvas, controller.page.strokes); if (controller.active != null) paintStrokes(canvas, [controller.active!]); }
  @override bool shouldRepaint(InkPainter oldDelegate) => oldDelegate.controller != controller;
}
class InkCanvas extends StatelessWidget {
  const InkCanvas({super.key, required this.controller, this.background});
  final DrawingController controller;
  final ui.Image? background;
  @override Widget build(BuildContext context) => Semantics(label: 'Handwriting page. Use the toolbar to draw, erase or move the page.', child: RepaintBoundary(child: SizedBox(width: controller.page.width, height: controller.page.height, child: Stack(fit: StackFit.expand, children: [ColoredBox(color: Colors.white, child: background == null ? null : RawImage(image: background, fit: BoxFit.fill)), Listener(behavior: HitTestBehavior.opaque, onPointerDown: controller.begin, onPointerMove: controller.move, onPointerUp: controller.end, onPointerCancel: controller.cancel, child: CustomPaint(painter: InkPainter(controller)))]))));
}
