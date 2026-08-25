import '../models/pattern.dart';

GPoint n(double x, double y) => GPoint(x, y - 0.5);
GPoint e(double x, double y) => GPoint(x + 0.5, y);
GPoint s(double x, double y) => GPoint(x, y + 0.5);
GPoint w(double x, double y) => GPoint(x - 0.5, y);

List<GPoint> _unique(List<GPoint> points) {
  final out = <GPoint>[];
  for (final p in points) {
    if (out.isEmpty || out.last != p) out.add(p);
  }
  if (out.length > 1 && out.first == out.last) out.removeLast();
  return out;
}

/// Rounded enclosure around a block of pullis.
/// 1×1 is a loop; 1×n is a capsule with straight sides.
List<GPoint> enclosure(num x0, num y0, num x1, num y1) {
  final minX = x0 < x1 ? x0.toDouble() : x1.toDouble();
  final maxX = x0 < x1 ? x1.toDouble() : x0.toDouble();
  final minY = y0 < y1 ? y0.toDouble() : y1.toDouble();
  final maxY = y0 < y1 ? y1.toDouble() : y0.toDouble();
  final pts = <GPoint>[w(minX, minY)];
  for (var x = minX; x <= maxX + 0.01; x += 1) {
    pts.add(n(x, minY));
  }
  pts.add(e(maxX, minY));
  for (var y = minY + 1; y <= maxY + 0.01; y += 1) {
    pts.add(e(maxX, y));
  }
  pts.add(s(maxX, maxY));
  for (var x = maxX - 1; x >= minX - 0.01; x -= 1) {
    pts.add(s(x, maxY));
  }
  pts.add(w(minX, maxY));
  for (var y = maxY - 1; y > minY + 0.01; y -= 1) {
    pts.add(w(minX, y));
  }
  return _unique(pts);
}

List<GPoint> loopAround(GPoint pulli) => enclosure(pulli.x, pulli.y, pulli.x, pulli.y);

List<GPoint> capsuleH(num x0, num y, num x1) => enclosure(x0, y, x1, y);

List<GPoint> capsuleV(num x, num y0, num y1) => enclosure(x, y0, x, y1);

List<List<GPoint>> cornerLoops(int size) {
  final last = size - 1.0;
  return [
    loopAround(GPoint(0, 0)),
    loopAround(GPoint(last, 0)),
    loopAround(GPoint(last, last)),
    loopAround(GPoint(0, last)),
  ];
}

/// Four corner loops + a plus of two overlapping capsules.
List<List<GPoint>> moolaiSiluvai(int size) {
  final mid = (size - 1) / 2;
  final last = size - 1.0;
  return [
    ...cornerLoops(size),
    capsuleH(0, mid, last),
    capsuleV(mid, 0, last),
  ];
}

List<GPoint> figureEightH(GPoint left) {
  final right = GPoint(left.x + 1, left.y);
  return [
    n(left.x, left.y),
    e(left.x, left.y),
    n(right.x, right.y),
    e(right.x, right.y),
    s(right.x, right.y),
    w(right.x, right.y),
    s(left.x, left.y),
    w(left.x, left.y),
  ];
}

KolamStroke stroke(String id, List<GPoint> points, {bool kaavi = false}) =>
    KolamStroke(id: id, points: points, kaavi: kaavi);

List<KolamStroke> strokesFrom(List<List<GPoint>> paths) {
  return [
    for (var i = 0; i < paths.length; i++) stroke('s$i', paths[i]),
  ];
}

List<GPoint> figureEightV(GPoint top) {
  final bottom = GPoint(top.x, top.y + 1);
  return [
    n(top.x, top.y),
    e(top.x, top.y),
    s(top.x, top.y),
    e(bottom.x, bottom.y),
    s(bottom.x, bottom.y),
    w(bottom.x, bottom.y),
    n(bottom.x, bottom.y),
    w(top.x, top.y),
  ];
}

KolamPattern kolam({
  required String id,
  required String name,
  required int rows,
  int? columns,
  required List<KolamStroke> strokes,
  int difficulty = 2,
  double previewSeconds = 3,
  int timeLimitSeconds = 70,
  String world = 'first_dots',
  String? culturalNote,
}) {
  return KolamPattern(
    id: id,
    name: name,
    rows: rows,
    columns: columns ?? rows,
    strokes: strokes,
    difficulty: difficulty,
    previewSeconds: previewSeconds,
    timeLimitSeconds: timeLimitSeconds,
    world: world,
    culturalNote: culturalNote,
  );
}

KolamPattern bindu({
  required String id,
  required int rows,
  required int columns,
  double previewSeconds = 4,
  int timeLimitSeconds = 45,
}) {
  final cx = (columns - 1) / 2;
  final cy = (rows - 1) / 2;
  return kolam(
    id: id,
    name: 'Bindu',
    rows: rows,
    columns: columns,
    difficulty: 1,
    previewSeconds: previewSeconds,
    timeLimitSeconds: timeLimitSeconds,
    strokes: [stroke('p1', loopAround(GPoint(cx, cy)))],
  );
}

KolamPattern kambi({
  required String id,
  required int rows,
  required int columns,
  bool vertical = false,
  double previewSeconds = 4,
  int timeLimitSeconds = 50,
}) {
  final lastC = columns - 1.0;
  final lastR = rows - 1.0;
  final midR = (rows - 1) / 2;
  final midC = (columns - 1) / 2;
  final pts = vertical ? capsuleV(midC, 0, lastR) : capsuleH(0, midR, lastC);
  return kolam(
    id: id,
    name: vertical ? 'Kambi' : 'Kambi',
    rows: rows,
    columns: columns,
    difficulty: 2,
    previewSeconds: previewSeconds,
    timeLimitSeconds: timeLimitSeconds,
    strokes: [stroke('p1', pts)],
  );
}

KolamPattern siluvai({
  required String id,
  required int rows,
  required int columns,
  double previewSeconds = 4,
  int timeLimitSeconds = 55,
}) {
  final lastC = columns - 1.0;
  final lastR = rows - 1.0;
  final midR = (rows - 1) / 2;
  final midC = (columns - 1) / 2;
  return kolam(
    id: id,
    name: 'Siluvai',
    rows: rows,
    columns: columns,
    difficulty: 2,
    previewSeconds: previewSeconds,
    timeLimitSeconds: timeLimitSeconds,
    strokes: [
      stroke('h', capsuleH(0, midR, lastC)),
      stroke('v', capsuleV(midC, 0, lastR)),
    ],
  );
}

KolamPattern moolaiSiluvaiKolam({
  required String id,
  required int rows,
  required int columns,
  double previewSeconds = 5,
  int timeLimitSeconds = 70,
}) {
  return kolam(
    id: id,
    name: 'Moolai Siluvai',
    rows: rows,
    columns: columns,
    difficulty: 3,
    previewSeconds: previewSeconds,
    timeLimitSeconds: timeLimitSeconds,
    strokes: strokesFrom(moolaiSiluvai(rows)),
  );
}
