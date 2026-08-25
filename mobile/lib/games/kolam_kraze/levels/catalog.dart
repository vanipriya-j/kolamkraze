import '../engine/builders.dart';
import '../engine/sikku.dart';
import '../models/enums.dart';
import '../models/pattern.dart';

class CatalogItem {
  const CatalogItem({
    required this.pattern,
    required this.world,
    required this.levelNumber,
    this.culturalNote,
  });

  final KolamPattern pattern;
  final PatternWorld world;
  final int levelNumber;
  final String? culturalNote;

  DifficultyFilter get difficultyBand {
    if (pattern.difficulty <= 2) return DifficultyFilter.easy;
    if (pattern.difficulty <= 4) return DifficultyFilter.medium;
    return DifficultyFilter.hard;
  }
}

class KolamCatalog {
  KolamCatalog._();

  static final List<CatalogItem> items = _build();

  static CatalogItem byId(String id) =>
      items.firstWhere((item) => item.pattern.id == id);

  static CatalogItem? tryById(String id) {
    for (final item in items) {
      if (item.pattern.id == id) return item;
    }
    return null;
  }

  static CatalogItem dailyFor(DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    return items[seed % items.length];
  }

  static List<CatalogItem> filtered({
    DifficultyFilter filter = DifficultyFilter.all,
    PatternWorld? world,
  }) {
    return items.where((item) {
      if (world != null && item.world != world) return false;
      if (filter != DifficultyFilter.all && item.difficultyBand != filter) {
        return false;
      }
      return true;
    }).toList();
  }
}

List<CatalogItem> _build() {
  final out = <CatalogItem>[];
  var n = 1;

  void add(
    KolamPattern pattern, {
    required PatternWorld world,
    String? note,
  }) {
    out.add(CatalogItem(
      pattern: pattern.copyWith(world: world.name, culturalNote: note),
      world: world,
      levelNumber: n++,
      culturalNote: note,
    ));
  }

  add(
    bindu(id: 'bindu-3', rows: 3, columns: 3, previewSeconds: 4, timeLimitSeconds: 45),
    world: PatternWorld.firstDots,
    note: 'A single pulli, held with a loop.',
  );
  add(
    sikkuKolam(
      id: 'sikku-malar',
      name: 'Malar',
      a: SikkuJoin.backslash,
      b: SikkuJoin.slash,
      c: SikkuJoin.slash,
      d: SikkuJoin.backslash,
      previewSeconds: 5,
      timeLimitSeconds: 70,
    ),
    world: PatternWorld.firstDots,
    note: 'A centre loop with a four-lobed sikku around the mid-side pullis.',
  );
  add(
    sikkuKolam(
      id: 'sikku-neli',
      name: 'Neli',
      a: SikkuJoin.cross,
      b: SikkuJoin.slash,
      c: SikkuJoin.cross,
      d: SikkuJoin.slash,
      previewSeconds: 5,
      timeLimitSeconds: 75,
    ),
    world: PatternWorld.firstDots,
    note: 'One continuous neli that weaves the 3×3 without lifting.',
  );
  add(
    kolam(
      id: 'sikku-prakara',
      name: 'Prakara Bindu',
      rows: 3,
      difficulty: 2,
      previewSeconds: 4,
      timeLimitSeconds: 60,
      strokes: [
        stroke('c', loopAround(const GPoint(1, 1))),
        stroke('o', enclosure(0, 0, 2, 2)),
      ],
    ),
    world: PatternWorld.firstDots,
    note: 'A small loop on the centre, then the outer walk around the eight.',
  );
  add(
    sikkuKolam(
      id: 'sikku-mudi',
      name: 'Sikku Mudi',
      a: SikkuJoin.slash,
      b: SikkuJoin.cross,
      c: SikkuJoin.cross,
      d: SikkuJoin.backslash,
      previewSeconds: 5,
      timeLimitSeconds: 75,
    ),
    world: PatternWorld.firstDots,
    note: 'A single knot that turns through the lattice.',
  );
  add(
    sikkuKolam(
      id: 'sikku-padi',
      name: 'Padi',
      a: SikkuJoin.slash,
      b: SikkuJoin.backslash,
      c: SikkuJoin.slash,
      d: SikkuJoin.backslash,
      previewSeconds: 5,
      timeLimitSeconds: 70,
    ),
    world: PatternWorld.firstDots,
    note: 'An indented sikku — same family, one side dips in.',
  );
  add(
    siluvai(id: 'siluvai-3', rows: 3, columns: 3, previewSeconds: 4, timeLimitSeconds: 55),
    world: PatternWorld.firstDots,
    note: 'Two kambis crossing at the centre.',
  );
  add(
    kolam(
      id: 'moolai-3',
      name: 'Moolai',
      rows: 3,
      difficulty: 2,
      previewSeconds: 4,
      timeLimitSeconds: 50,
      strokes: strokesFrom(cornerLoops(3)),
    ),
    world: PatternWorld.firstDots,
    note: 'A small loop around each corner pulli.',
  );
  add(
    moolaiSiluvaiKolam(id: 'moolai-siluvai', rows: 3, columns: 3, previewSeconds: 5, timeLimitSeconds: 70),
    world: PatternWorld.firstDots,
    note: 'Corner loops with a crossing at the heart.',
  );

  add(kambi(id: 'kambi-4h', rows: 4, columns: 4, vertical: false), world: PatternWorld.growing);
  add(siluvai(id: 'siluvai-4', rows: 4, columns: 4), world: PatternWorld.growing);
  add(
    kolam(
      id: 'moolai-4',
      name: 'Corner Cross 4×4',
      rows: 4,
      difficulty: 3,
      previewSeconds: 4,
      timeLimitSeconds: 70,
      strokes: [
        ...strokesFrom(cornerLoops(4)),
        stroke('h', capsuleH(0, 1.5, 3)),
        stroke('v', capsuleV(1.5, 0, 3)),
      ],
    ),
    world: PatternWorld.growing,
  );
  add(
    kolam(
      id: 'frame-4',
      name: 'Inner Frame',
      rows: 4,
      difficulty: 3,
      previewSeconds: 4,
      timeLimitSeconds: 65,
      strokes: [stroke('p1', enclosure(0, 0, 3, 3))],
    ),
    world: PatternWorld.growing,
  );

  add(kambi(id: 'kambi-5h', rows: 5, columns: 5, vertical: false, previewSeconds: 3), world: PatternWorld.growing);
  add(siluvai(id: 'siluvai-5', rows: 5, columns: 5, previewSeconds: 3), world: PatternWorld.growing);
  add(
    moolaiSiluvaiKolam(id: 'moolai-5', rows: 5, columns: 5, previewSeconds: 3, timeLimitSeconds: 80)
        .copyWith(name: 'Growing Siluvai'),
    world: PatternWorld.growing,
  );
  add(
    kolam(
      id: 'nested-5',
      name: 'Nested Frames',
      rows: 5,
      difficulty: 3,
      previewSeconds: 3,
      timeLimitSeconds: 80,
      strokes: [
        stroke('o', enclosure(0, 0, 4, 4)),
        stroke('i', enclosure(1, 1, 3, 3)),
        stroke('c', loopAround(GPoint(2, 2))),
      ],
    ),
    world: PatternWorld.growing,
  );
  add(
    kolam(
      id: 'padi-5',
      name: 'Three Steps',
      rows: 5,
      difficulty: 3,
      previewSeconds: 3,
      timeLimitSeconds: 75,
      strokes: [
        stroke('a', enclosure(0, 0, 4, 4)),
        stroke('b', enclosure(1, 1, 3, 3)),
        stroke('c', enclosure(2, 2, 2, 2)),
      ],
    ),
    world: PatternWorld.growing,
  );
  add(
    kolam(
      id: 'figure-5',
      name: 'Linked Eights',
      rows: 5,
      difficulty: 4,
      previewSeconds: 3,
      timeLimitSeconds: 80,
      strokes: [stroke('p1', figureEightH(GPoint(1, 2)))],
    ),
    world: PatternWorld.growing,
  );

  add(siluvai(id: 'siluvai-6', rows: 6, columns: 6, previewSeconds: 3), world: PatternWorld.growing);
  add(
    kolam(
      id: 'corners-6',
      name: 'Corner Lattice',
      rows: 6,
      difficulty: 4,
      previewSeconds: 3,
      timeLimitSeconds: 90,
      strokes: [
        ...strokesFrom(cornerLoops(6)),
        stroke('h', capsuleH(1, 2.5, 4)),
        stroke('v', capsuleV(2.5, 1, 4)),
        stroke('f', enclosure(1, 1, 4, 4)),
      ],
    ),
    world: PatternWorld.growing,
  );

  add(
    kolam(
      id: 'loops-7',
      name: 'Loop Garden',
      rows: 7,
      difficulty: 4,
      previewSeconds: 3,
      timeLimitSeconds: 95,
      strokes: [
        stroke('o', enclosure(0, 0, 6, 6)),
        stroke('i', enclosure(2, 2, 4, 4)),
        stroke('a', loopAround(GPoint(1, 1))),
        stroke('b', loopAround(GPoint(1, 5))),
        stroke('c', loopAround(GPoint(5, 1))),
        stroke('d', loopAround(GPoint(5, 5))),
        stroke('e', loopAround(GPoint(3, 3))),
      ],
    ),
    world: PatternWorld.loops,
  );
  add(
    kolam(
      id: 'kattu-7',
      name: 'Kattu 7',
      rows: 7,
      difficulty: 4,
      previewSeconds: 3,
      timeLimitSeconds: 100,
      strokes: [
        stroke('o', enclosure(0, 0, 6, 6)),
        stroke('h', capsuleH(1, 3, 5)),
        stroke('v', capsuleV(3, 1, 5)),
        stroke('a', loopAround(GPoint(1, 1))),
        stroke('b', loopAround(GPoint(1, 5))),
        stroke('c', loopAround(GPoint(5, 1))),
        stroke('d', loopAround(GPoint(5, 5))),
      ],
    ),
    world: PatternWorld.loops,
  );
  add(
    kolam(
      id: 'padi-7',
      name: 'Stepped Courtyard',
      rows: 7,
      difficulty: 4,
      previewSeconds: 2,
      timeLimitSeconds: 100,
      strokes: [
        stroke('a', enclosure(0, 0, 6, 6)),
        stroke('b', enclosure(1, 1, 5, 5)),
        stroke('c', enclosure(2, 2, 4, 4)),
        stroke('d', loopAround(GPoint(3, 3))),
      ],
    ),
    world: PatternWorld.loops,
  );
  add(siluvai(id: 'siluvai-7', rows: 7, columns: 7, previewSeconds: 2), world: PatternWorld.loops);

  add(
    kolam(
      id: 'sym-8',
      name: 'Mirror Court',
      rows: 8,
      difficulty: 5,
      previewSeconds: 2,
      timeLimitSeconds: 110,
      strokes: [
        stroke('o', enclosure(0, 0, 7, 7)),
        stroke('i', enclosure(2, 2, 5, 5)),
        ...strokesFrom(cornerLoops(8)),
        stroke('h', capsuleH(1, 3.5, 6)),
        stroke('v', capsuleV(3.5, 1, 6)),
      ],
    ),
    world: PatternWorld.symmetry,
  );
  add(
    kolam(
      id: 'padi-9',
      name: 'Ninefold',
      rows: 9,
      difficulty: 5,
      previewSeconds: 2,
      timeLimitSeconds: 120,
      strokes: [
        stroke('a', enclosure(0, 0, 8, 8)),
        stroke('b', enclosure(2, 2, 6, 6)),
        stroke('c', enclosure(3, 3, 5, 5)),
        stroke('d', loopAround(GPoint(4, 4))),
        stroke('e', loopAround(GPoint(1, 1))),
        stroke('f', loopAround(GPoint(1, 7))),
        stroke('g', loopAround(GPoint(7, 1))),
        stroke('h', loopAround(GPoint(7, 7))),
      ],
    ),
    world: PatternWorld.symmetry,
  );
  add(
    kolam(
      id: 'kattu-9',
      name: 'Tied Nine',
      rows: 9,
      difficulty: 5,
      previewSeconds: 2,
      timeLimitSeconds: 120,
      strokes: [
        stroke('o', enclosure(0, 0, 8, 8)),
        stroke('h', capsuleH(1, 4, 7)),
        stroke('v', capsuleV(4, 1, 7)),
        stroke('h2', capsuleH(2, 2, 6)),
        stroke('v2', capsuleV(2, 2, 6)),
        ...strokesFrom(cornerLoops(9)),
      ],
    ),
    world: PatternWorld.symmetry,
  );
  add(
    kolam(
      id: 'lotus-11',
      name: 'Courtyard Lotus',
      rows: 11,
      difficulty: 6,
      previewSeconds: 2,
      timeLimitSeconds: 140,
      strokes: [
        stroke('a', enclosure(0, 0, 10, 10)),
        stroke('b', enclosure(2, 2, 8, 8)),
        stroke('c', enclosure(4, 4, 6, 6)),
        stroke('d', loopAround(GPoint(5, 5))),
        stroke('e', loopAround(GPoint(1, 5))),
        stroke('f', loopAround(GPoint(9, 5))),
        stroke('g', loopAround(GPoint(5, 1))),
        stroke('h', loopAround(GPoint(5, 9))),
        stroke('i', capsuleH(2, 5, 8)),
        stroke('j', capsuleV(5, 2, 8)),
      ],
    ),
    world: PatternWorld.symmetry,
  );

  add(
    kolam(
      id: 'master-13',
      name: 'Temple Court',
      rows: 13,
      difficulty: 7,
      previewSeconds: 1,
      timeLimitSeconds: 160,
      strokes: [
        stroke('a', enclosure(0, 0, 12, 12)),
        stroke('b', enclosure(2, 2, 10, 10)),
        stroke('c', enclosure(4, 4, 8, 8)),
        stroke('d', enclosure(5, 5, 7, 7)),
        stroke('e', loopAround(GPoint(6, 6))),
        ...strokesFrom(cornerLoops(13)),
        stroke('h', capsuleH(2, 6, 10)),
        stroke('v', capsuleV(6, 2, 10)),
      ],
    ),
    world: PatternWorld.master,
  );
  add(
    kolam(
      id: 'master-15',
      name: 'Festival Field',
      rows: 15,
      difficulty: 8,
      previewSeconds: 1,
      timeLimitSeconds: 180,
      strokes: [
        stroke('a', enclosure(0, 0, 14, 14)),
        stroke('b', enclosure(2, 2, 12, 12)),
        stroke('c', enclosure(4, 4, 10, 10)),
        stroke('d', enclosure(6, 6, 8, 8)),
        stroke('e', loopAround(GPoint(7, 7))),
        stroke('f', loopAround(GPoint(1, 1))),
        stroke('g', loopAround(GPoint(1, 13))),
        stroke('h', loopAround(GPoint(13, 1))),
        stroke('i', loopAround(GPoint(13, 13))),
        stroke('j', capsuleH(3, 7, 11)),
        stroke('k', capsuleV(7, 3, 11)),
      ],
    ),
    world: PatternWorld.master,
  );

  return out;
}
