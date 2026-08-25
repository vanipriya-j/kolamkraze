import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/design/assets.dart';
import '../../../core/design/colors.dart';

/// Splash and home hero: [AarlaAssets.mark] when present, else a drawn sikku.
class LandingMark extends StatelessWidget {
  const LandingMark({super.key, this.cornerRadius = 20});

  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cornerRadius),
        child: OptionalAssetImage(
          asset: AarlaAssets.mark,
          fit: BoxFit.contain,
          fallback: LandingSikku(fillBackground: true, cornerRadius: cornerRadius),
        ),
      ),
    );
  }
}

/// Drawn cream-on-kaavi diamond sikku, used only if [AarlaAssets.mark] is missing.
///
/// Pullis sit on a 5×5 square lattice rotated 45° (checkerboard of manhattan
/// radius 4): rows 1-2-3-4-5-4-3-2-1. Each pulli sits in a diamond cell.
/// Convex outer corners become teardrop loops around the outermost pullis.
class LandingSikku extends StatelessWidget {
  const LandingSikku({
    super.key,
    this.fillBackground = true,
    this.cornerRadius = 20,
  });

  final bool fillBackground;
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cornerRadius),
        child: CustomPaint(
          painter: LandingSikkuPainter(fillBackground: fillBackground),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class LandingSikkuPainter extends CustomPainter {
  const LandingSikkuPainter({this.fillBackground = true});

  final bool fillBackground;

  @override
  void paint(Canvas canvas, Size size) {
    if (fillBackground) {
      canvas.drawRect(Offset.zero & size, Paint()..color = AarlaColors.kaaviDeep);
    }

    final geom = LandingSikkuGeometry.build();
    final scale = size.shortestSide / LandingSikkuGeometry.span;
    final origin = Offset(size.width / 2, size.height / 2);
    Offset map(LandingPt p) => origin + Offset(p.x.toDouble(), p.y.toDouble()) * scale;
    Offset mapD(Offset p) => origin + p * scale;

    final stroke = Paint()
      ..color = AarlaColors.kolamCream
      ..style = PaintingStyle.stroke
      ..strokeWidth = (size.shortestSide * 0.032).clamp(2.8, 6.0)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final path = Path();
    for (final e in geom.internalEdges) {
      final a = map(e.$1);
      final b = map(e.$2);
      path.moveTo(a.dx, a.dy);
      path.lineTo(b.dx, b.dy);
    }

    final cycle = geom.boundary;
    if (cycle.length >= 3) {
      final n = cycle.length;
      var startIdx = cycle.indexWhere((v) => !geom.peaks.contains(v));
      if (startIdx < 0) startIdx = 0;
      path.moveTo(map(cycle[startIdx]).dx, map(cycle[startIdx]).dy);
      var i = 0;
      while (i < n) {
        final idx = (startIdx + i + 1) % n;
        final v = cycle[idx];
        if (geom.peaks.contains(v)) {
          final prev = cycle[(idx - 1 + n) % n];
          final next = cycle[(idx + 1) % n];
          final to = map(next);
          final owner = geom.ownerOf(v);
          if (owner == null) {
            final ext = mapD(Offset(v.x.toDouble(), v.y.toDouble()) * 1.22);
            path.quadraticBezierTo(ext.dx, ext.dy, to.dx, to.dy);
          } else {
            final from = map(prev);
            final center = map(owner);
            final radius = (from - center).distance;
            final start = math.atan2(from.dy - center.dy, from.dx - center.dx);
            final through = math.atan2(map(v).dy - center.dy, map(v).dx - center.dx);
            final end = math.atan2(to.dy - center.dy, to.dx - center.dx);
            final sweep = _sweepThrough(start, end, through);
            path.arcTo(
              Rect.fromCircle(center: center, radius: radius),
              start,
              sweep,
              false,
            );
          }
          i += 2;
        } else {
          final p = map(v);
          path.lineTo(p.dx, p.dy);
          i += 1;
        }
      }
    }

    canvas.drawPath(path, stroke);

    final dotPaint = Paint()
      ..color = AarlaColors.kolamCream
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final dotR = (size.shortestSide * 0.0145).clamp(2.4, 5.0);
    for (final p in geom.pullis) {
      canvas.drawCircle(map(p), dotR, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant LandingSikkuPainter oldDelegate) =>
      oldDelegate.fillBackground != fillBackground;
}

/// Clockwise-positive sweep from [start] to [end] that passes [through].
double _sweepThrough(double start, double end, double through) {
  const tau = math.pi * 2;
  double norm(double a) {
    var x = a % tau;
    if (x < 0) x += tau;
    return x;
  }

  final cw = norm(end - start);
  final th = norm(through - start);
  final onCw = th > 1e-6 && th < cw - 1e-6;
  if (onCw) return cw;
  final ccw = cw - tau;
  return ccw == 0 ? -tau + 1e-6 : ccw;
}

class LandingPt {
  const LandingPt(this.x, this.y);
  final int x;
  final int y;

  LandingPt operator +(LandingPt o) => LandingPt(x + o.x, y + o.y);

  @override
  bool operator ==(Object other) => other is LandingPt && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);
}

class LandingSikkuGeometry {
  LandingSikkuGeometry._({
    required this.pullis,
    required this.internalEdges,
    required this.boundary,
    required this.peaks,
  });

  static const extent = 4;

  /// Lattice units from center to the far teardrop, plus margin.
  static const span = 12.4;

  final List<LandingPt> pullis;
  final List<(LandingPt, LandingPt)> internalEdges;
  final List<LandingPt> boundary;
  final Set<LandingPt> peaks;

  static final _vertexDirs = const [LandingPt(0, -1), LandingPt(1, 0), LandingPt(0, 1), LandingPt(-1, 0)];
  static final _across = const [LandingPt(1, -1), LandingPt(1, 1), LandingPt(-1, 1), LandingPt(-1, -1)];

  static bool isPulli(LandingPt p) => (p.x + p.y).isEven && p.x.abs() + p.y.abs() <= extent;

  LandingPt? ownerOf(LandingPt vertex) {
    final cands = <LandingPt>[
      LandingPt(vertex.x, vertex.y + 1),
      LandingPt(vertex.x, vertex.y - 1),
      LandingPt(vertex.x - 1, vertex.y),
      LandingPt(vertex.x + 1, vertex.y),
    ].where(isPulli).toList();
    if (cands.isEmpty) return null;
    cands.sort((a, b) => (a.x * a.x + a.y * a.y).compareTo(b.x * b.x + b.y * b.y));
    return cands.first;
  }

  static LandingSikkuGeometry build() {
    final pullis = <LandingPt>[];
    for (var y = -extent; y <= extent; y++) {
      for (var x = -extent; x <= extent; x++) {
        final p = LandingPt(x, y);
        if (isPulli(p)) pullis.add(p);
      }
    }

    final internal = <(int, int, int, int)>{};
    final adj = <LandingPt, Set<LandingPt>>{};
    void link(LandingPt a, LandingPt b) {
      adj.putIfAbsent(a, () => <LandingPt>{}).add(b);
      adj.putIfAbsent(b, () => <LandingPt>{}).add(a);
    }

    (LandingPt, LandingPt) ordered(LandingPt a, LandingPt b) {
      if (a.x < b.x || (a.x == b.x && a.y <= b.y)) return (a, b);
      return (b, a);
    }

    for (final p in pullis) {
      for (var i = 0; i < 4; i++) {
        final a = p + _vertexDirs[i];
        final b = p + _vertexDirs[(i + 1) % 4];
        final neighbor = p + _across[i];
        if (isPulli(neighbor)) {
          final e = ordered(a, b);
          internal.add((e.$1.x, e.$1.y, e.$2.x, e.$2.y));
        } else {
          link(a, b);
        }
      }
    }

    final internalEdges = internal.map((e) => (LandingPt(e.$1, e.$2), LandingPt(e.$3, e.$4))).toList();

    final start = LandingPt(0, -extent - 1);
    final boundary = <LandingPt>[];
    if (adj.containsKey(start) && adj[start]!.isNotEmpty) {
      var prev = start;
      var cur = adj[start]!.first;
      boundary.add(start);
      var guard = 0;
      while (cur != start && guard++ < 80) {
        boundary.add(cur);
        final ns = adj[cur]!.toList();
        final next = ns[0] == prev ? ns[1] : ns[0];
        prev = cur;
        cur = next;
      }
    }

    final centroid = Offset.zero;
    final peaks = <LandingPt>{};
    if (boundary.length >= 3) {
      for (var i = 0; i < boundary.length; i++) {
        final prev = boundary[(i - 1 + boundary.length) % boundary.length];
        final v = boundary[i];
        final next = boundary[(i + 1) % boundary.length];
        final vo = Offset(v.x.toDouble(), v.y.toDouble());
        final mid = Offset((prev.x + next.x) / 2.0, (prev.y + next.y) / 2.0);
        if ((vo - centroid).distance > (mid - centroid).distance + 0.05) {
          peaks.add(v);
        }
      }
    }

    return LandingSikkuGeometry._(
      pullis: pullis,
      internalEdges: internalEdges,
      boundary: boundary,
      peaks: peaks,
    );
  }
}
