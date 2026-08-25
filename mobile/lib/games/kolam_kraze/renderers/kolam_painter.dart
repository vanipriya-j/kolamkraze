import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../core/design/colors.dart';
import '../engine/geometry.dart';
import '../models/enums.dart';
import '../models/pattern.dart';

class KolamPainter extends CustomPainter {
  KolamPainter({
    required this.pattern,
    required this.material,
    required this.kaavi,
    this.playerStrokes = const [],
    this.liveStroke = const [],
    this.showPattern = true,
    this.showDots = true,
    this.patternOpacity = 1,
    this.guidance = false,
    this.progress = 1,
    this.paintSurface = true,
  });

  final KolamPattern pattern;
  final KolamMaterial material;
  final bool kaavi;
  final List<List<Offset>> playerStrokes;
  final List<Offset> liveStroke;
  final bool showPattern;
  final bool showDots;
  final double patternOpacity;
  final bool guidance;
  final double progress;
  final bool paintSurface;

  @override
  void paint(Canvas canvas, Size size) {
    if (paintSurface) _paintSurface(canvas, size);
    if (kaavi) _paintKaavi(canvas, size);
    if (showDots) _paintDots(canvas, size);
    if (showPattern) _paintPattern(canvas, size);
    if (guidance && !showPattern) {
      _paintPattern(canvas, size);
    }
    for (final stroke in playerStrokes) {
      _paintStroke(canvas, stroke, player: true);
    }
    if (liveStroke.length >= 2) {
      _paintStroke(canvas, liveStroke, player: true);
    }
  }

  void _paintSurface(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final colors = switch (material) {
      KolamMaterial.chalkpiece => [AarlaColors.slate, const Color(0xFF1A2228), AarlaColors.charcoal],
      KolamMaterial.kolaMaavu => [const Color(0xFF7A2E24), AarlaColors.oxide, const Color(0xFF5C241C)],
      KolamMaterial.ezhaiKolam => [const Color(0xFF6B5344), AarlaColors.stone, const Color(0xFF4A3A30)],
      KolamMaterial.rangoli => [const Color(0xFF3D1A28), AarlaColors.maroon, const Color(0xFF5C2A1A)],
    };
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ).createShader(rect),
    );
    final grit = Paint()..color = Colors.white.withValues(alpha: 0.035);
    for (var i = 0; i < 90; i++) {
      final x = (i * 47) % size.width;
      final y = (i * 89) % size.height;
      canvas.drawCircle(Offset(x, y), 1.1, grit);
    }
  }

  void _paintKaavi(Canvas canvas, Size size) {
    final inset = size.shortestSide * 0.06;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(inset, inset, size.width - inset * 2, size.height - inset * 2),
      const Radius.circular(18),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = AarlaColors.kaavi
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawRRect(
      rrect.deflate(8),
      Paint()
        ..color = AarlaColors.kaavi.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  void _paintDots(Canvas canvas, Size size) {
    final layout = GridLayout.fromSize(pattern.rows, pattern.columns, size);
    final paint = Paint()..color = AarlaColors.pulli.withValues(alpha: 0.92);
    for (var r = 0; r < pattern.rows; r++) {
      for (var c = 0; c < pattern.columns; c++) {
        canvas.drawCircle(layout.dot(r, c), layout.cell * 0.09, paint);
      }
    }
  }

  void _paintPattern(Canvas canvas, Size size) {
    final samples = samplePattern(pattern, size);
    if (samples.length < 2) return;
    final end = (samples.length * progress.clamp(0, 1)).floor().clamp(2, samples.length);
    _paintStroke(canvas, samples.sublist(0, end), player: false, opacity: patternOpacity);
  }

  void _paintStroke(Canvas canvas, List<Offset> pts, {required bool player, double opacity = 1}) {
    if (pts.length < 2) return;
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      final prev = pts[i - 1];
      final cur = pts[i];
      final mid = Offset((prev.dx + cur.dx) / 2, (prev.dy + cur.dy) / 2);
      path.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
    }
    path.lineTo(pts.last.dx, pts.last.dy);

    final color = _strokeColor(player).withValues(alpha: opacity);
    final width = _width();
    switch (material) {
      case KolamMaterial.chalkpiece:
        canvas.drawPath(
          path,
          Paint()
            ..color = color.withValues(alpha: 0.22 * opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = width * 1.8
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.4),
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = width
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      case KolamMaterial.kolaMaavu:
        canvas.drawPath(
          path,
          Paint()
            ..color = color.withValues(alpha: 0.35 * opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = width * 1.35
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.6),
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = width * 0.92
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
        _dust(canvas, pts, color);
      case KolamMaterial.ezhaiKolam:
        canvas.drawPath(
          path,
          Paint()
            ..color = color.withValues(alpha: 0.28 * opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = width * 1.55
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = width * 1.12
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      case KolamMaterial.rangoli:
        final rainbow = [
          AarlaColors.turmeric,
          AarlaColors.oxide,
          AarlaColors.mutedGreen,
          AarlaColors.indigo,
          AarlaColors.ivory,
        ];
        for (var i = 1; i < pts.length; i++) {
          final c = rainbow[i % rainbow.length].withValues(alpha: opacity);
          canvas.drawLine(
            pts[i - 1],
            pts[i],
            Paint()
              ..color = c
              ..strokeWidth = width
              ..strokeCap = StrokeCap.round
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.6),
          );
        }
        _dust(canvas, pts, color);
    }
  }

  void _dust(Canvas canvas, List<Offset> pts, Color color) {
    final paint = Paint()..color = color.withValues(alpha: 0.18);
    for (var i = 0; i < pts.length; i += 3) {
      final jiggle = math.sin(i * 1.7) * 2.2;
      canvas.drawCircle(pts[i] + Offset(jiggle, -jiggle * 0.4), 1.4, paint);
    }
  }

  Color _strokeColor(bool player) {
    if (!player && material == KolamMaterial.rangoli) return AarlaColors.ivory;
    return switch (material) {
      KolamMaterial.chalkpiece => const Color(0xFFF4F1EA),
      KolamMaterial.kolaMaavu => const Color(0xFFFAF6EE),
      KolamMaterial.ezhaiKolam => const Color(0xFFFFF8EC),
      KolamMaterial.rangoli => AarlaColors.ivory,
    };
  }

  double _width() => switch (material) {
        KolamMaterial.chalkpiece => 5.2,
        KolamMaterial.kolaMaavu => 6.4,
        KolamMaterial.ezhaiKolam => 7.4,
        KolamMaterial.rangoli => 6.8,
      };

  @override
  bool shouldRepaint(covariant KolamPainter old) =>
      old.pattern.id != pattern.id ||
      old.material != material ||
      old.kaavi != kaavi ||
      old.showPattern != showPattern ||
      old.patternOpacity != patternOpacity ||
      old.progress != progress ||
      old.playerStrokes != playerStrokes ||
      old.liveStroke != liveStroke ||
      old.showDots != showDots ||
      old.paintSurface != paintSurface;
}
