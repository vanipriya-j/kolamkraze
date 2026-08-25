import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kolam_kraze/games/kolam_kraze/engine/geometry.dart';
import 'package:kolam_kraze/games/kolam_kraze/levels/catalog.dart';
import 'package:kolam_kraze/games/kolam_kraze/models/enums.dart';
import 'package:kolam_kraze/games/kolam_kraze/models/pattern.dart';
import 'package:kolam_kraze/games/kolam_kraze/renderers/kolam_painter.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  test('classic 3×3 patterns paint as rounded enclosures', () async {
    final first = KolamCatalog.filtered(world: PatternWorld.firstDots);
    expect(first, hasLength(9));

    final dir = Directory('/tmp/kolam-3x3')..createSync(recursive: true);
    const cell = 160.0;
    const pad = 24.0;
    final sheet = Size(pad * 2 + cell * 3, pad * 2 + cell * 3 + 36);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(Offset.zero & sheet, Paint()..color = const Color(0xFF2A0F16));

    for (var i = 0; i < first.length; i++) {
      final item = first[i];
      final col = i % 3;
      final row = i ~/ 3;
      final origin = Offset(pad + col * cell, pad + row * cell);
      canvas.save();
      canvas.translate(origin.dx, origin.dy);
      const tile = Size(148, 148);
      KolamPainter(
        pattern: item.pattern,
        material: KolamMaterial.kolaMaavu,
        kaavi: false,
        showPattern: true,
        showDots: true,
      ).paint(canvas, tile);
      canvas.restore();
      final tp = TextPainter(
        text: TextSpan(
          text: item.pattern.name,
          style: const TextStyle(color: Color(0xFFFAF6EE), fontSize: 12, fontWeight: FontWeight.w700),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 148);
      tp.paint(canvas, origin + Offset((148 - tp.width) / 2, 150));

      final bytes = await _pngOf(item.pattern, const Size(420, 420));
      File('${dir.path}/${item.pattern.id}.png').writeAsBytesSync(bytes);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(sheet.width.round(), sheet.height.round());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    File('${dir.path}/first_dots_3x3.png').writeAsBytesSync(data!.buffer.asUint8List());

    const size = Size(300, 300);
    final bindu = KolamCatalog.byId('bindu-3').pattern;
    final layout = GridLayout.fromSize(3, 3, size);
    final samples = expandStroke(bindu.strokes.first, layout);
    final pulli = layout.dot(1, 1);
    final minD = samples.map((p) => (p - pulli).distance).reduce((a, b) => a < b ? a : b);
    expect(minD, greaterThan(0.42 * layout.cell));
  });
}

Future<List<int>> _pngOf(KolamPattern pattern, Size size) async {
  final recorder = ui.PictureRecorder();
  KolamPainter(
    pattern: pattern,
    material: KolamMaterial.kolaMaavu,
    kaavi: false,
    showPattern: true,
    showDots: true,
  ).paint(Canvas(recorder), size);
  final image = await recorder.endRecording().toImage(size.width.round(), size.height.round());
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}
