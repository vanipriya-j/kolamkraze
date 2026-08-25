import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../models/pattern.dart';
import '../renderers/kolam_painter.dart';

class KolamDrawGame extends FlameGame {
  KolamDrawGame({
    required this.pattern,
    required this.material,
    required this.kaavi,
    this.instant = false,
    this.duration = 4,
  });

  final KolamPattern pattern;
  final KolamMaterial material;
  final bool kaavi;
  final bool instant;
  final double duration;

  double elapsed = 0;

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    add(_KolamDrawComponent(
      pattern: pattern,
      material: material,
      kaavi: kaavi,
      instant: instant,
      duration: duration,
    ));
  }
}

class _KolamDrawComponent extends PositionComponent {
  _KolamDrawComponent({
    required this.pattern,
    required this.material,
    required this.kaavi,
    required this.instant,
    required this.duration,
  });

  final KolamPattern pattern;
  final KolamMaterial material;
  final bool kaavi;
  final bool instant;
  final double duration;
  double t = 0;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  void update(double dt) {
    super.update(dt);
    t += dt;
  }

  @override
  void render(Canvas canvas) {
    final progress = instant ? 1.0 : (t / duration).clamp(0.0, 1.0);
    KolamPainter(
      pattern: pattern,
      material: material,
      kaavi: kaavi,
      showPattern: true,
      progress: progress,
    ).paint(canvas, Size(size.x, size.y));
  }
}

class KolamDrawView extends StatelessWidget {
  const KolamDrawView({
    super.key,
    required this.pattern,
    required this.material,
    required this.kaavi,
    this.instant = false,
  });

  final KolamPattern pattern;
  final KolamMaterial material;
  final bool kaavi;
  final bool instant;

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: KolamDrawGame(
        pattern: pattern,
        material: material,
        kaavi: kaavi,
        instant: instant,
      ),
    );
  }
}
