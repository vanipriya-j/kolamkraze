import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kolam_kraze/games/kolam_kraze/engine/builders.dart';
import 'package:kolam_kraze/games/kolam_kraze/engine/geometry.dart';
import 'package:kolam_kraze/games/kolam_kraze/levels/catalog.dart';
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
