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

Offset magnetizeToStrokes(
  Offset p,
  List<List<Offset>> strokes, {
  double radius = 28,
  double strength = 0.35,
}) {
  if (strokes.isEmpty) return p;
  Offset? best;
  var bestD = double.infinity;
  for (final stroke in strokes) {
    if (stroke.length < 2) continue;
    final n = nearestOnPolyline(p, stroke);
    final d = (p - n).distance;
    if (d < bestD) {
      bestD = d;
      best = n;
    }
  }
  if (best == null || bestD > radius) return p;
  return Offset.lerp(p, best, strength)!;
}

double nearestDistanceToStrokes(Offset p, List<List<Offset>> strokes) {
  var best = double.infinity;
  for (final stroke in strokes) {
    final d = nearestDistance(p, stroke);
    if (d < best) best = d;
  }
  return best;
}

List<GPoint> _cardinalPullis(GPoint p) {
  final x = (p.x * 2).round() / 2.0;
  final y = (p.y * 2).round() / 2.0;
  final xHalf = (x * 2).round().abs() % 2 == 1;
  final yHalf = (y * 2).round().abs() % 2 == 1;
  if (xHalf && !yHalf) {
    return [GPoint(x - 0.5, y), GPoint(x + 0.5, y)];
  }
  if (yHalf && !xHalf) {
    return [GPoint(x, y - 0.5), GPoint(x, y + 0.5)];
  }
  return const [];
}

GPoint? sharedPulli(GPoint a, GPoint b) {
  final pa = _cardinalPullis(a);
  final pb = _cardinalPullis(b);
  for (final p in pa) {
    for (final q in pb) {
      if (p == q) return p;
    }
  }
  return null;
}

/// Turns lattice points into a kolam curve: petal wraps around pullis, straight kambi runs.
///
/// A circular quarter-arc (κ ≈ 0.552) makes bindu a circle. Real sikku/neli
/// wraps are petals — they pinch on the diagonal between two cardinals.
List<Offset> expandStroke(KolamStroke stroke, GridLayout layout, {int arcSteps = 12}) {
  if (stroke.points.isEmpty) return const [];
  final pts = [...stroke.points];
  if (stroke.closed && pts.first != pts.last) {
    pts.add(pts.first);
  }
  final out = <Offset>[layout.point(pts.first)];
  for (var i = 1; i < pts.length; i++) {
    final a = pts[i - 1];
    final b = pts[i];
    final pulli = sharedPulli(a, b);
    if (pulli != null && a != b) {
      out.addAll(_petalArc(layout.point(a), layout.point(b), layout.point(pulli), arcSteps).skip(1));
    } else {
      final start = out.last;
      final end = layout.point(b);
      final steps = math.max(1, ((end - start).distance / 5).round());
      for (var s = 1; s <= steps; s++) {
        out.add(Offset.lerp(start, end, s / steps)!);
      }
    }
  }
  return out;
}

/// Cubic κ ≈ 0.552 is a circle. Lower κ pinches the diagonal into a petal
/// (rounded diamond with tips at the cardinals). Higher κ makes a squircle.
const double kKolamPetalKappa = 0.40;

List<Offset> _petalArc(Offset start, Offset end, Offset center, int steps) {
  var a0 = math.atan2(start.dy - center.dy, start.dx - center.dx);
  var a1 = math.atan2(end.dy - center.dy, end.dx - center.dx);
  var delta = a1 - a0;
  while (delta > math.pi) {
    delta -= 2 * math.pi;
  }
  while (delta < -math.pi) {
    delta += 2 * math.pi;
  }
  final radius = (start - center).distance;
  if (radius < 0.001) return [start, end];

  Offset tangent(double ang) => Offset(-math.sin(ang), math.cos(ang));
  final dir = delta >= 0 ? 1.0 : -1.0;
  final handle = kKolamPetalKappa * radius;
  final p1 = start + tangent(a0) * (dir * handle);
  final p2 = end - tangent(a1) * (dir * handle);

  final out = <Offset>[start];
  for (var s = 1; s <= steps; s++) {
    out.add(_cubic(start, p1, p2, end, s / steps));
  }
  return out;
}

Offset _cubic(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
  final u = 1 - t;
  final uu = u * u;
  final tt = t * t;
  return p0 * (uu * u) + p1 * (3 * uu * t) + p2 * (3 * u * tt) + p3 * (tt * t);
}

List<Offset> sampleStroke(KolamStroke stroke, GridLayout layout, {int density = 12}) {
  final curved = expandStroke(stroke, layout, arcSteps: math.max(8, density));
  if (curved.length < 2) return curved;
  return resamplePolyline(curved, math.max(24, curved.length));
}

List<List<Offset>> samplePatternStrokes(KolamPattern pattern, Size size) {
  final layout = GridLayout.fromSize(pattern.rows, pattern.columns, size);
  return [for (final stroke in pattern.strokes) sampleStroke(stroke, layout)];
}

List<Offset> samplePattern(KolamPattern pattern, Size size) {
  return samplePatternStrokes(pattern, size).expand((stroke) => stroke).toList();
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
