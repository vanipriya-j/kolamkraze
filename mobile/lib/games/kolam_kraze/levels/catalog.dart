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

  static bool get isEmpty => items.isEmpty;

  /// 3×3 dots only — UI fallback, not a playable kolam.
  static const placeholder = KolamPattern(
    id: '_empty',
    name: '',
    rows: 3,
    columns: 3,
    strokes: [],
    difficulty: 1,
  );

  static CatalogItem byId(String id) {
    final item = tryById(id);
    if (item == null) {
      throw StateError('No kolam "$id" — catalog is waiting for the six 3×3 references.');
    }
    return item;
  }

  static CatalogItem? tryById(String id) {
    for (final item in items) {
      if (item.pattern.id == id) return item;
    }
    return null;
  }

  static CatalogItem? dailyFor(DateTime date) {
    if (items.isEmpty) return null;
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

/// Playable set is empty until the six 3×3 reference kolams are uploaded
/// and traced exactly. Approximations stay out of the catalog.
List<CatalogItem> _build() => const [];
