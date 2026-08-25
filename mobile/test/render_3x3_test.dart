import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kolam_kraze/games/kolam_kraze/levels/catalog.dart';
import 'package:kolam_kraze/games/kolam_kraze/models/enums.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  test('playable catalog waits for the six 3×3 references', () {
    expect(KolamCatalog.items, isEmpty);
    expect(KolamCatalog.filtered(world: PatternWorld.firstDots), isEmpty);
    expect(KolamCatalog.dailyFor(DateTime.now()), isNull);
  });
}
