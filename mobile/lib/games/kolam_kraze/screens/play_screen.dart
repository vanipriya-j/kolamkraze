import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_controller.dart';
import '../../../core/analytics/analytics.dart';
import '../../../core/design/colors.dart';
import '../audio/kolam_audio.dart';
import '../levels/catalog.dart';
import '../models/enums.dart';
import '../scoring/scorer.dart';
import '../widgets/kolam_canvas.dart';

enum _Phase { look, countdown, ready, flash, draw }

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  final _board = GlobalKey<KolamCanvasState>();
  _Phase _phase = _Phase.look;
  int _count = 3;
  int _seconds = 0;
  int _peeks = 0;
  bool _peeking = false;
  bool _started = false;
  Timer? _tick;
  Timer? _phaseTimer;
  List<List<Offset>> _strokes = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final app = AppScope.of(context);
    KolamAudio.instance.soundOn = app.store.soundOn;
    KolamAudio.instance.hapticsOn = app.store.hapticsOn;
    _startForMode(app.mode);
  }

  void _startForMode(PlayMode mode) {
    Analytics.instance.playStarted();
    switch (mode) {
      case PlayMode.copy:
        _enterDraw();
      case PlayMode.memory:
        _beginLook();
      case PlayMode.flash:
        setState(() => _phase = _Phase.ready);
        _phaseTimer = Timer(const Duration(milliseconds: 900), () {
          if (!mounted) return;
          setState(() => _phase = _Phase.flash);
          _phaseTimer = Timer(const Duration(milliseconds: 450), _beginLook);
        });
    }
  }

  double _previewSeconds() {
    final app = AppScope.of(context);
    final item = KolamCatalog.tryById(app.patternId);
    if (item == null) return 3;
    var seconds = item.pattern.previewSeconds;
    if (app.mode == PlayMode.flash) {
      if (item.pattern.difficulty >= 7) {
        seconds = 1;
      } else if (item.pattern.difficulty >= 5) {
        seconds = 2;
      } else {
        seconds = 3;
      }
    }
    if (app.store.reducedMotion) seconds = seconds + 2;
    return seconds;
  }

  void _beginLook() {
    Analytics.instance.previewStarted();
    setState(() => _phase = _Phase.look);
    final preview = _previewSeconds();
    final countPart = preview >= 3 ? 3.0 : 0.0;
    final look = (preview - countPart).clamp(0.4, 12.0);
    _phaseTimer?.cancel();
    _phaseTimer = Timer(Duration(milliseconds: (look * 1000).round()), () {
      if (!mounted) return;
      if (countPart > 0 && AppScope.of(context).mode == PlayMode.memory) {
        _beginCountdown();
      } else {
        Analytics.instance.previewCompleted();
        _enterDraw();
      }
    });
  }

  void _beginCountdown() {
    setState(() {
      _phase = _Phase.countdown;
      _count = 3;
    });
    _phaseTimer?.cancel();
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_count <= 1) {
        t.cancel();
        Analytics.instance.previewCompleted();
        _enterDraw();
      } else {
        setState(() => _count -= 1);
      }
    });
  }

  void _enterDraw() {
    _phaseTimer?.cancel();
    setState(() {
      _phase = _Phase.draw;
      _seconds = 0;
    });
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _seconds += 1);
    });
  }

  Future<void> _peek() async {
    if (_peeks >= 2 || _peeking) return;
    Analytics.instance.peekUsed();
    KolamAudio.instance.peek();
    setState(() {
      _peeks += 1;
      _peeking = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (mounted) setState(() => _peeking = false);
  }

  void _check() {
    final app = AppScope.of(context);
    final board = _board.currentState;
    final strokes = board?.strokes ?? _strokes;
    final size = board?.canvasSize ?? const Size(400, 400);
    final item = KolamCatalog.tryById(app.patternId);
    if (item == null) return;
    final result = KolamScorer.score(
      pattern: item.pattern,
      playerStrokes: strokes,
      timeSeconds: _seconds,
      peekUsed: _peeks,
      canvasSize: size,
    );
    KolamAudio.instance.complete();
    app.recordResult(result, strokes, size);
    context.push('/play/results');
  }

  @override
  void dispose() {
    _tick?.cancel();
    _phaseTimer?.cancel();
    super.dispose();
  }

  String _clock(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final r = (s % 60).toString().padLeft(2, '0');
    return '$m:$r';
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final item = KolamCatalog.tryById(app.patternId);
    if (item == null) {
      return Scaffold(
        backgroundColor: AarlaColors.ivory,
        appBar: AppBar(title: const Text('Play')),
        body: const Center(child: Text('No kolam selected.')),
      );
    }
    final drawing = _phase == _Phase.draw;
    final showPattern = !drawing || _peeking || app.mode == PlayMode.copy;
    final wide = MediaQuery.sizeOf(context).shortestSide >= 600 && app.mode == PlayMode.copy;

    final board = KolamCanvas(
      key: _board,
      pattern: item.pattern,
      material: app.material,
      kaavi: app.kaavi,
      showPattern: app.mode == PlayMode.copy ? false : showPattern && _phase != _Phase.ready && _phase != _Phase.flash,
      patternOpacity: _peeking ? 0.45 : (_phase == _Phase.look || _phase == _Phase.countdown ? 1 : 0),
      interactive: drawing,
      onStrokeStart: () {
        Analytics.instance.strokeStarted();
        KolamAudio.instance.stroke(app.material);
      },
      onStrokesChanged: (s) => _strokes = s,
    );

    Widget stage;
    if (_phase == _Phase.ready) {
      stage = _CenterWord('READY');
    } else if (_phase == _Phase.flash) {
      stage = _CenterWord('FLASH!');
    } else if (wide) {
      stage = Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: KolamThumb(pattern: item.pattern, material: app.material, kaavi: app.kaavi),
            ),
          ),
          Expanded(flex: 3, child: board),
        ],
      );
    } else {
      stage = Column(
        children: [
          if (app.mode == PlayMode.copy)
            SizedBox(
              height: 108,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: KolamThumb(pattern: item.pattern, material: app.material, kaavi: app.kaavi),
              ),
            ),
          Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: ClipRRect(borderRadius: BorderRadius.circular(24), child: board))),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AarlaColors.charcoal,
      appBar: AppBar(
        backgroundColor: AarlaColors.charcoal,
        foregroundColor: AarlaColors.ivory,
        title: Text('${app.mode.label}  ·  Level ${item.levelNumber}  ·  ${item.pattern.rows}×${item.pattern.columns}'),
        actions: [
          if (drawing)
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 14),
              child: Text(_clock(_seconds), style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()], fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_phase == _Phase.look)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('LOOK CAREFULLY', style: TextStyle(color: AarlaColors.turmeric, letterSpacing: 2, fontWeight: FontWeight.w800)),
            ),
          if (_phase == _Phase.countdown)
            Text('$_count', style: const TextStyle(color: AarlaColors.ivory, fontSize: 56, fontWeight: FontWeight.w700)),
          Expanded(child: stage),
          if (drawing)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  children: [
                    _Tool('Undo', () {
                      Analytics.instance.undoUsed();
                      _board.currentState?.undo();
                    }),
                    _Tool('Clear', () => _board.currentState?.clear()),
                    if (app.mode == PlayMode.memory) _Tool('Peek', _peeks >= 2 ? null : _peek),
                    const Spacer(),
                    FilledButton(
                      onPressed: _check,
                      style: FilledButton.styleFrom(backgroundColor: AarlaColors.turmeric, foregroundColor: AarlaColors.charcoal),
                      child: const Text('CHECK', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CenterWord extends StatelessWidget {
  const _CenterWord(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text, style: const TextStyle(color: AarlaColors.ivory, fontSize: 48, fontWeight: FontWeight.w800, letterSpacing: 4)),
    );
  }
}

class _Tool extends StatelessWidget {
  const _Tool(this.label, this.onTap);
  final String label;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(label, style: const TextStyle(color: AarlaColors.ivory, fontWeight: FontWeight.w700)),
    );
  }
}
