import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kolam_kraze/games/kolam_kraze/engine/builders.dart';
import 'package:kolam_kraze/games/kolam_kraze/engine/geometry.dart';
import 'package:kolam_kraze/games/kolam_kraze/engine/sikku.dart';
import 'package:kolam_kraze/games/kolam_kraze/levels/catalog.dart';
import 'package:kolam_kraze/games/kolam_kraze/models/enums.dart';
import 'package:kolam_kraze/games/kolam_kraze/models/pattern.dart';
import 'package:kolam_kraze/games/kolam_kraze/scoring/scorer.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('enclosures', () {
    test('a 1×1 enclosure is a four-point loop around one pulli', () {
      final loop = loopAround(const GPoint(1, 1));
      expect(loop, hasLength(4));
      expect(loop.contains(const GPoint(1, 0.5)), isTrue);
    });

    test('a horizontal kambi has straight runs, not a circle of loops', () {
      final line = capsuleH(0, 1, 2);
      expect(line.length, greaterThan(4));
      expect(line.where((p) => p.y == 0.5).length, greaterThanOrEqualTo(2));
    });

    test('moolai siluvai is four corner loops plus a crossing', () {
      final paths = moolaiSiluvai(3);
      expect(paths, hasLength(6));
    });

    test('a bindu loop is a petal around the pulli, not a circle', () {
      const size = Size(300, 300);
      final pattern = KolamCatalog.byId('bindu-3').pattern;
      final layout = GridLayout.fromSize(pattern.rows, pattern.columns, size);
      final samples = expandStroke(pattern.strokes.first, layout);
      final pulli = layout.dot(1, 1);
      var minD = double.infinity;
      var maxD = 0.0;
      for (final p in samples) {
        final d = (p - pulli).distance;
        if (d < minD) minD = d;
        if (d > maxD) maxD = d;
      }
      // Cardinals stay on the lattice (~0.5 cell). Diagonals pinch into petals.
      expect(minD, greaterThan(0.38 * layout.cell));
      expect(maxD, lessThan(0.58 * layout.cell));
      expect((maxD - minD) / minD, greaterThan(0.08));
    });

    test('a 3×3 sikku from cell joins is a closed weave', () {
      final plus = sikkuJoins(SikkuJoin.cross, SikkuJoin.cross, SikkuJoin.cross, SikkuJoin.cross);
      expect(plus, hasLength(2));
      final oneLine = sikkuJoins(SikkuJoin.cross, SikkuJoin.slash, SikkuJoin.cross, SikkuJoin.slash);
      expect(oneLine, hasLength(1));
      expect(oneLine.first.length, greaterThan(8));
    });
  });

  group('catalog', () {
    test('every level has a unique id and at least one stroke', () {
      final ids = KolamCatalog.items.map((e) => e.pattern.id).toSet();
      expect(ids.length, KolamCatalog.items.length);
      expect(KolamCatalog.items.every((e) => e.pattern.strokes.isNotEmpty), isTrue);
      expect(KolamCatalog.items.first.pattern.rows, 3);
      expect(KolamCatalog.items.last.pattern.rows, 15);
    });

    test('json round-trips a pattern', () {
      final original = KolamCatalog.byId('moolai-siluvai').pattern;
      final copy = KolamPattern.fromJson(original.toJson());
      expect(copy.id, original.id);
      expect(copy.strokes.length, original.strokes.length);
      expect(copy.rows, 3);
    });

    test('First Dots is the 3×3 sikku set', () {
      final first = KolamCatalog.filtered(world: PatternWorld.firstDots);
      expect(first.every((e) => e.pattern.rows == 3 && e.pattern.columns == 3), isTrue);
      expect(first.map((e) => e.pattern.id).toList(), [
        'bindu-3',
        'sikku-malar',
        'sikku-neli',
        'sikku-prakara',
        'sikku-mudi',
        'sikku-padi',
        'siluvai-3',
        'moolai-3',
        'moolai-siluvai',
      ]);
      expect(KolamCatalog.byId('sikku-neli').pattern.strokes, hasLength(1));
      expect(KolamCatalog.byId('kambi-4h').world, PatternWorld.growing);
    });
  });

  group('scoring', () {
    test('an empty drawing scores poorly', () {
      final pattern = KolamCatalog.byId('bindu-3').pattern;
      final result = KolamScorer.score(
        pattern: pattern,
        playerStrokes: const [],
        timeSeconds: 40,
        peekUsed: 0,
      );
      expect(result.stars, 0);
      expect(result.completion, 0);
    });

    test('tracing the intended path scores highly', () {
      const size = Size(400, 400);
      final pattern = KolamCatalog.byId('moolai-siluvai').pattern;
      final samples = samplePattern(pattern, size);
      final result = KolamScorer.score(
        pattern: pattern,
        playerStrokes: [samples],
        timeSeconds: 18,
        peekUsed: 0,
        canvasSize: size,
      );
      expect(result.completion, greaterThan(80));
      expect(result.accuracy, greaterThan(70));
      expect(result.stars, greaterThanOrEqualTo(2));
    });
  });
}
