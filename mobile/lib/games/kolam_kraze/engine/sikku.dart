import '../models/pattern.dart';
import 'builders.dart';

/// Junction inside one unit cell of four pullis.
///
/// `cross` is both straights (the hash through the cell).
/// `slash` is /  (arcs around the NE and SW pullis).
/// `backslash` is \  (arcs around the NW and SE pullis).
enum SikkuJoin { cross, slash, backslash }

class _Graph {
  final Map<GPoint, List<GPoint>> adj = {};

  void add(GPoint a, GPoint b) {
    if (a == b) return;
    adj.putIfAbsent(a, () => []).add(b);
    adj.putIfAbsent(b, () => []).add(a);
  }

  int deg(GPoint p) => adj[p]?.length ?? 0;

  bool has(GPoint a, GPoint b) => adj[a]?.contains(b) ?? false;
}

/// 3×3 sikku from a 2×2 of cell junctions, completed around each pulli.
List<List<GPoint>> sikku3(List<List<SikkuJoin>> cells) {
  assert(cells.length == 2 && cells.every((row) => row.length == 2));
  final g = _Graph();

  for (var j = 0; j < 2; j++) {
    for (var i = 0; i < 2; i++) {
      final t = e(i.toDouble(), j.toDouble());
      final r = s(i + 1.0, j.toDouble());
      final b = e(i.toDouble(), j + 1.0);
      final l = s(i.toDouble(), j.toDouble());
      switch (cells[j][i]) {
        case SikkuJoin.cross:
          g.add(t, b);
          g.add(l, r);
        case SikkuJoin.slash:
          g.add(t, r);
          g.add(l, b);
        case SikkuJoin.backslash:
          g.add(t, l);
          g.add(r, b);
      }
    }
  }

  const edgeCenters = [
    [1, 0],
    [2, 1],
    [1, 2],
    [0, 1],
  ];
  const corners = [
    [0, 0],
    [2, 0],
    [2, 2],
    [0, 2],
  ];
  for (final p in [...edgeCenters, ...corners, [1, 1]]) {
    _closePulli(g, p[0], p[1]);
  }

  final dangling = [
    for (final entry in g.adj.entries)
      if (entry.value.length != 2) '${entry.key.x},${entry.key.y}:${entry.value.length}'
  ];
  if (dangling.isNotEmpty) {
    throw StateError('dangling $dangling');
  }

  return _cycles(g);
}

void _closePulli(_Graph g, int x, int y) {
  final px = x.toDouble();
  final py = y.toDouble();
  final ring = [n(px, py), e(px, py), s(px, py), w(px, py)];
  for (var k = 0; k < 4; k++) {
    final a = ring[k];
    final b = ring[(k + 1) % 4];
    if (g.deg(a) >= 2 || g.deg(b) >= 2) continue;
    if (g.deg(a) == 0 && g.deg(b) == 0) continue;
    if (g.has(a, b)) continue;
    g.add(a, b);
  }
}

List<List<GPoint>> _cycles(_Graph g) {
  final unused = <GPoint, List<GPoint>>{};
  for (final e in g.adj.entries) {
    unused[e.key] = List.of(e.value);
  }

  GPoint? take(GPoint from) {
    final nbs = unused[from];
    if (nbs == null || nbs.isEmpty) return null;
    final to = nbs.removeLast();
    unused[to]?.remove(from);
    return to;
  }

  final out = <List<GPoint>>[];
  final starts = [...g.adj.keys];
  for (final start in starts) {
    if ((unused[start] ?? const []).isEmpty) continue;
    final loop = <GPoint>[start];
    var cur = start;
    while (true) {
      final next = take(cur);
      if (next == null) break;
      if (next == start) break;
      loop.add(next);
      cur = next;
    }
    if (loop.length >= 3) out.add(_unique(loop));
  }
  return out;
}

List<GPoint> _unique(List<GPoint> points) {
  final out = <GPoint>[];
  for (final p in points) {
    if (out.isEmpty || out.last != p) out.add(p);
  }
  if (out.length > 1 && out.first == out.last) out.removeLast();
  return out;
}

List<List<GPoint>> sikkuJoins(
  SikkuJoin a,
  SikkuJoin b,
  SikkuJoin c,
  SikkuJoin d,
) =>
    sikku3([
      [a, b],
      [c, d],
    ]);

KolamPattern sikkuKolam({
  required String id,
  required String name,
  required SikkuJoin a,
  required SikkuJoin b,
  required SikkuJoin c,
  required SikkuJoin d,
  int difficulty = 3,
  double previewSeconds = 4,
  int timeLimitSeconds = 60,
}) {
  return kolam(
    id: id,
    name: name,
    rows: 3,
    difficulty: difficulty,
    previewSeconds: previewSeconds,
    timeLimitSeconds: timeLimitSeconds,
    strokes: strokesFrom(sikkuJoins(a, b, c, d)),
  );
}
