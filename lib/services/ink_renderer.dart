import 'dart:ui';

import '../domain/models.dart';

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
