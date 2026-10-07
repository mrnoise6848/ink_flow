import 'dart:ui';
import 'dart:math';

import '../domain/models.dart';

void paintStrokes(Canvas canvas, Iterable<InkStroke> strokes) {
  for (final stroke in strokes) {
    if (stroke.points.isEmpty) continue;
    final translucent = stroke.opacity < 1;
    if (translucent) {
      var left = stroke.points.first.x,
          right = left,
          top = stroke.points.first.y,
          bottom = top;
      for (final p in stroke.points) {
        left = min(left, p.x);
        right = max(right, p.x);
        top = min(top, p.y);
        bottom = max(bottom, p.y);
      }
      canvas.saveLayer(
        Rect.fromLTRB(left, top, right, bottom).inflate(stroke.width + 1),
        Paint()
          ..color = const Color(0xff000000).withValues(alpha: stroke.opacity),
      );
    }
    final paint = Paint()
      ..color = Color(stroke.color).withValues(alpha: 1)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (stroke.points.length == 1) {
      final p = stroke.points.first;
      canvas.drawCircle(Offset(p.x, p.y), stroke.width * p.pressure / 2, paint);
      if (translucent) canvas.restore();
      continue;
    }
    for (var i = 1; i < stroke.points.length; i++) {
      final a = stroke.points[i - 1], b = stroke.points[i];
      paint.strokeWidth = stroke.width * (a.pressure + b.pressure) / 2;
      canvas.drawLine(Offset(a.x, a.y), Offset(b.x, b.y), paint);
    }
    if (translucent) canvas.restore();
  }
}
