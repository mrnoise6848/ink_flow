import 'dart:math';

String newId() => '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}-${Random.secure().nextInt(1 << 32).toRadixString(36)}';

class Notebook {
  Notebook({required this.id, required this.title});
  final String id;
  String title;
  Map<String, dynamic> toJson() => {'id': id, 'title': title};
  factory Notebook.fromJson(Map<String, dynamic> j) => Notebook(id: j['id'] as String, title: j['title'] as String);
}

class InkDocument {
  InkDocument({required this.id, required this.title, required this.notebookId, DateTime? created, DateTime? modified, List<String>? pages, List<String>? tags, this.favorite = false})
      : created = created ?? DateTime.now(), modified = modified ?? DateTime.now(), pages = pages ?? [], tags = tags ?? [];
  final String id;
  String title;
  String notebookId;
  final DateTime created;
  DateTime modified;
  final List<String> pages;
  List<String> tags;
  bool favorite;
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'notebook': notebookId, 'created': created.toIso8601String(), 'modified': modified.toIso8601String(), 'pages': pages, 'tags': tags, 'favorite': favorite};
  factory InkDocument.fromJson(Map<String, dynamic> j) => InkDocument(id: j['id'] as String, title: j['title'] as String, notebookId: j['notebook'] as String, created: DateTime.parse(j['created'] as String), modified: DateTime.parse(j['modified'] as String), pages: List<String>.from(j['pages'] as List), tags: List<String>.from(j['tags'] as List), favorite: j['favorite'] as bool);
}

class InkPoint {
  const InkPoint(this.x, this.y, [this.pressure = 1]);
  final double x, y, pressure;
  List<double> toJson() => [x, y, pressure];
  factory InkPoint.fromJson(List<dynamic> j) {
    final x = (j[0] as num).toDouble(), y = (j[1] as num).toDouble(), p = (j[2] as num).toDouble();
    if (!x.isFinite || !y.isFinite || !p.isFinite) { throw const FormatException('Invalid ink point'); }
    return InkPoint(x, y, p.clamp(0.05, 1));
  }
}

class InkStroke {
  InkStroke({required this.points, required this.color, required this.width, this.opacity = 1, this.device = 'touch', this.pressureSupported = false});
  final List<InkPoint> points;
  final int color;
  final double width, opacity;
  final String device;
  final bool pressureSupported;
  Map<String, dynamic> toJson() => {'points': points.map((p) => p.toJson()).toList(), 'color': color, 'width': width, 'opacity': opacity, 'device': device, 'pressure': pressureSupported};
  factory InkStroke.fromJson(Map<String, dynamic> j) => InkStroke(points: (j['points'] as List).map((p) => InkPoint.fromJson(p as List)).toList(), color: j['color'] as int, width: ((j['width'] as num).toDouble()).clamp(0.5, 40), opacity: ((j['opacity'] as num).toDouble()).clamp(0.05, 1), device: j['device'] as String, pressureSupported: j['pressure'] as bool);
}

class InkPage {
  InkPage({required this.id, this.width = 595, this.height = 842, this.background, this.pdfPage, List<InkStroke>? strokes}) : strokes = strokes ?? [];
  final String id;
  final double width, height;
  // Private relative asset name; original imported files are never overwritten.
  final String? background;
  final int? pdfPage;
  final List<InkStroke> strokes;
  Map<String, dynamic> toJson() => {'version': 1, 'id': id, 'width': width, 'height': height, 'background': background, 'pdfPage': pdfPage, 'strokes': strokes.map((s) => s.toJson()).toList()};
  factory InkPage.fromJson(Map<String, dynamic> j) {
    if (j['version'] != 1) { throw const FormatException('Unsupported page version'); }
    final w = (j['width'] as num).toDouble(), h = (j['height'] as num).toDouble();
    if (!w.isFinite || !h.isFinite || w <= 0 || h <= 0 || w > 20000 || h > 20000) { throw const FormatException('Invalid page dimensions'); }
    return InkPage(id: j['id'] as String, width: w, height: h, background: j['background'] as String?, pdfPage: j['pdfPage'] as int?, strokes: (j['strokes'] as List).map((s) => InkStroke.fromJson(s as Map<String, dynamic>)).toList());
  }
}
