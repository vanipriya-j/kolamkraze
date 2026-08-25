import 'package:flutter/material.dart';

import '../../../core/design/colors.dart';
import '../engine/geometry.dart';
import '../models/enums.dart';
import '../models/pattern.dart';
import '../renderers/kolam_painter.dart';

class KolamCanvas extends StatefulWidget {
  const KolamCanvas({
    super.key,
    required this.pattern,
    required this.material,
    required this.kaavi,
    this.showPattern = false,
    this.showDots = true,
    this.patternOpacity = 1,
    this.progress = 1,
    this.interactive = true,
    this.guidance = false,
    this.strokes = const [],
    this.onStrokesChanged,
    this.onStrokeStart,
  });

  final KolamPattern pattern;
  final KolamMaterial material;
  final bool kaavi;
  final bool showPattern;
  final bool showDots;
  final double patternOpacity;
  final double progress;
  final bool interactive;
  final bool guidance;
  final List<List<Offset>> strokes;
  final ValueChanged<List<List<Offset>>>? onStrokesChanged;
  final VoidCallback? onStrokeStart;

  @override
  State<KolamCanvas> createState() => KolamCanvasState();
}

class KolamCanvasState extends State<KolamCanvas> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _live = [];
  Size _size = const Size(400, 400);
  List<Offset> _expected = [];

  List<List<Offset>> get strokes => List.unmodifiable(_strokes);
  Size get canvasSize => _size;

  @override
  void initState() {
    super.initState();
    _strokes.addAll(widget.strokes.map((s) => List<Offset>.from(s)));
  }

  @override
  void didUpdateWidget(covariant KolamCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pattern.id != widget.pattern.id) {
      _strokes.clear();
      _live = [];
    }
  }

  void undo() {
    if (_strokes.isEmpty) return;
    setState(() => _strokes.removeLast());
    widget.onStrokesChanged?.call(strokes);
  }

  void clear() {
    setState(() {
      _strokes.clear();
      _live = [];
    });
    widget.onStrokesChanged?.call(strokes);
  }

  void _ensureExpected(Size size) {
    if (_size != size || _expected.isEmpty) {
      _size = size;
      _expected = samplePattern(widget.pattern, size);
    }
  }

  Offset _assist(Offset p) => magnetize(p, _expected, radius: 32, strength: 0.32);

  void _start(Offset p) {
    widget.onStrokeStart?.call();
    setState(() => _live = [_assist(p)]);
  }

  void _move(Offset p) {
    final next = _assist(p);
    if (_live.isEmpty) {
      setState(() => _live = [next]);
      return;
    }
    if ((next - _live.last).distance < 2.2) return;
    setState(() => _live = [..._live, next]);
  }

  void _end() {
    if (_live.length < 2) {
      setState(() => _live = []);
      return;
    }
    setState(() {
      _strokes.add(List.of(_live));
      _live = [];
    });
    widget.onStrokesChanged?.call(strokes);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _ensureExpected(size);
        final painter = KolamPainter(
          pattern: widget.pattern,
          material: widget.material,
          kaavi: widget.kaavi,
          playerStrokes: _strokes,
          liveStroke: _live,
          showPattern: widget.showPattern,
          showDots: widget.showDots,
          patternOpacity: widget.patternOpacity,
          guidance: widget.guidance,
          progress: widget.progress,
        );
        final child = CustomPaint(painter: painter, size: size);
        if (!widget.interactive) return child;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (d) => _start(d.localPosition),
          onPanUpdate: (d) => _move(d.localPosition),
          onPanEnd: (_) => _end(),
          child: child,
        );
      },
    );
  }
}

class KolamThumb extends StatelessWidget {
  const KolamThumb({
    super.key,
    required this.pattern,
    this.material = KolamMaterial.kolaMaavu,
    this.kaavi = false,
    this.showPattern = true,
  });

  final KolamPattern pattern;
  final KolamMaterial material;
  final bool kaavi;
  final bool showPattern;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: KolamPainter(
            pattern: pattern,
            material: material,
            kaavi: kaavi,
            showPattern: showPattern,
            showDots: true,
          ),
        ),
      ),
    );
  }
}

class AarlaButton extends StatelessWidget {
  const AarlaButton({
    super.key,
    required this.label,
    required this.onTap,
    this.filled = true,
    this.color,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onTap;
  final bool filled;
  final Color? color;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AarlaColors.maroon;
    final child = Text(
      label,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: filled ? AarlaColors.ivory : bg,
      ),
    );
    return SizedBox(
      width: expand ? double.infinity : null,
      height: 52,
      child: filled
          ? FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: bg,
                foregroundColor: AarlaColors.ivory,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: child,
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: bg,
                side: BorderSide(color: bg.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: child,
            ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.light = false});
  final String text;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
        color: light ? AarlaColors.ivory.withValues(alpha: 0.7) : AarlaColors.maroon.withValues(alpha: 0.7),
      ),
    );
  }
}
