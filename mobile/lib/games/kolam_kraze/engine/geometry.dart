import 'dart:math' as math;
import 'dart:ui';

import '../models/pattern.dart';

class GridLayout {
  GridLayout.fromSize(this.rows, this.columns, Size size) {
    final shortest = math.min(size.width, size.height);
    final span = math.max(rows, columns).toDouble();
    padding = shortest * 0.12;
    cell = (shortest - padding * 2) / span;
    origin = Offset(
      (size.width - cell * span) / 2,
      (size.height - cell * span) / 2,
    );
  }

  final int rows;
  final int columns;
  late final double padding;
  late final double cell;
  late final Offset origin;

  Offset point(GPoint p) =>
      origin + Offset((p.x + 0.5) * cell, (p.y + 0.5) * cell);

  Offset dot(int row, int col) => point(GPoint(col.toDouble(), row.toDouble()));

  GPoint toGrid(Offset o) {
    final x = (o.dx - origin.dx) / cell - 0.5;
    final y = (o.dy - origin.dy) / cell - 0.5;
    return GPoint(x, y);
  }
}

List<Offset> resamplePolyline(List<Offset> pts, int count) {
  if (pts.length < 2 || count < 2) return List.of(pts);
  final lengths = <double>[0];
  var total = 0.0;
  for (var i = 1; i < pts.length; i++) {
    total += (pts[i] - pts[i - 1]).distance;
    lengths.add(total);
  }
  if (total <= 0.001) return List.of(pts);
  final out = <Offset>[];
  for (var i = 0; i < count; i++) {
    final d = total * (i / (count - 1));
    var seg = 1;
    while (seg < lengths.length && lengths[seg] < d) {
      seg++;
    }
    final a = pts[seg - 1];
    final b = pts[math.min(seg, pts.length - 1)];
    final span = lengths[math.min(seg, lengths.length - 1)] - lengths[seg - 1];
    final t = span < 0.0001 ? 0.0 : (d - lengths[seg - 1]) / span;
    out.add(Offset.lerp(a, b, t.clamp(0.0, 1.0))!);
  }
  return out;
}

double nearestDistance(Offset p, List<Offset> pts) {
  if (pts.isEmpty) return 999;
  var best = double.infinity;
  for (var i = 1; i < pts.length; i++) {
    final d = _pointToSegment(p, pts[i - 1], pts[i]);
    if (d < best) best = d;
  }
  if (pts.length == 1) best = (p - pts.first).distance;
  return best;
}

Offset nearestOnPolyline(Offset p, List<Offset> pts) {
  if (pts.isEmpty) return p;
  var best = pts.first;
  var bestD = double.infinity;
  for (var i = 1; i < pts.length; i++) {
    final proj = _project(p, pts[i - 1], pts[i]);
    final d = (p - proj).distance;
    if (d < bestD) {
      bestD = d;
      best = proj;
    }
  }
  return best;
}

Offset magnetize(Offset p, List<Offset> expected, {double radius = 28, double strength = 0.35}) {
  if (expected.isEmpty) return p;
  final n = nearestOnPolyline(p, expected);
  final d = (p - n).distance;
  if (d > radius) return p;
  return Offset.lerp(p, n, strength)!;
}

List<Offset> sampleStroke(KolamStroke stroke, GridLayout layout, {int density = 12}) {
  var pts = stroke.points.map(layout.point).toList();
  if (stroke.closed && pts.isNotEmpty) {
    pts = [...pts, pts.first];
  }
  return resamplePolyline(pts, math.max(24, pts.length * density));
}

List<Offset> samplePattern(KolamPattern pattern, Size size) {
  final layout = GridLayout.fromSize(pattern.rows, pattern.columns, size);
  final out = <Offset>[];
  for (final stroke in pattern.strokes) {
    out.addAll(sampleStroke(stroke, layout));
  }
  return out;
}

double _pointToSegment(Offset p, Offset a, Offset b) {
  return (p - _project(p, a, b)).distance;
}

Offset _project(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final denom = ab.dx * ab.dx + ab.dy * ab.dy;
  if (denom < 0.0001) return a;
  final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / denom).clamp(0.0, 1.0);
  return a + ab * t;
}
