import 'dart:math' as math;
import 'dart:ui';

import '../engine/geometry.dart';
import '../models/pattern.dart';

class ScoreResult {
  const ScoreResult({
    required this.accuracy,
    required this.completion,
    required this.timeSeconds,
    required this.mistakes,
    required this.flowBonus,
    required this.score,
    required this.stars,
    required this.peekUsed,
  });

  final int accuracy;
  final int completion;
  final int timeSeconds;
  final int mistakes;
  final int flowBonus;
  final int score;
  final int stars;
  final int peekUsed;

  Map<String, dynamic> toJson() => {
        'accuracy': accuracy,
        'completion': completion,
        'timeSeconds': timeSeconds,
        'mistakes': mistakes,
        'flowBonus': flowBonus,
        'score': score,
        'stars': stars,
        'peekUsed': peekUsed,
      };

  factory ScoreResult.fromJson(Map<String, dynamic> json) => ScoreResult(
        accuracy: json['accuracy'] as int,
        completion: json['completion'] as int,
        timeSeconds: json['timeSeconds'] as int,
        mistakes: json['mistakes'] as int,
        flowBonus: json['flowBonus'] as int,
        score: json['score'] as int,
        stars: json['stars'] as int,
        peekUsed: json['peekUsed'] as int? ?? 0,
      );
}

class KolamScorer {
  KolamScorer._();

  static ScoreResult score({
    required KolamPattern pattern,
    required List<List<Offset>> playerStrokes,
    required int timeSeconds,
    required int peekUsed,
    Size canvasSize = const Size(400, 400),
  }) {
    final expected = samplePattern(pattern, canvasSize);
    if (expected.isEmpty) {
      return const ScoreResult(
        accuracy: 0,
        completion: 0,
        timeSeconds: 0,
        mistakes: 0,
        flowBonus: 0,
        score: 0,
        stars: 0,
        peekUsed: 0,
      );
    }

    final player = <Offset>[];
    for (final stroke in playerStrokes) {
      player.addAll(resamplePolyline(stroke, math.max(8, stroke.length * 4)));
    }

    const coverRadius = 18.0;
    const mistakeRadius = 28.0;

    var covered = 0;
    var distSum = 0.0;
    var distCount = 0;
    for (final e in expected) {
      if (player.isEmpty) continue;
      final d = nearestDistance(e, player);
      distSum += d;
      distCount++;
      if (d <= coverRadius) covered++;
    }

    var stray = 0;
    for (final p in player) {
      if (nearestDistance(p, expected) > mistakeRadius) stray++;
    }

    final completion = expected.isEmpty
        ? 0
        : ((covered / expected.length) * 100).round().clamp(0, 100);
    final meanDist = distCount == 0 ? 40.0 : distSum / distCount;
    final accuracy = (100 - meanDist * 2.4).round().clamp(0, 100);

    final mistakes = (stray / 18).round().clamp(0, 40) + peekUsed;
    final flow = _flowBonus(playerStrokes);
    final speed = _speedBonus(timeSeconds, pattern.timeLimitSeconds);

    var score = accuracy * 8 + completion * 6 + flow + speed - mistakes * 18 - peekUsed * 40;
    score = math.max(0, score);

    var stars = 0;
    if (completion >= 55 && accuracy >= 50) stars = 1;
    if (completion >= 75 && accuracy >= 70) stars = 2;
    if (completion >= 90 && accuracy >= 85 && mistakes <= 4) stars = 3;

    return ScoreResult(
      accuracy: accuracy,
      completion: completion,
      timeSeconds: timeSeconds,
      mistakes: mistakes,
      flowBonus: flow,
      score: score,
      stars: stars,
      peekUsed: peekUsed,
    );
  }

  static int _flowBonus(List<List<Offset>> strokes) {
    if (strokes.isEmpty) return 0;
    var bonus = 80;
    if (strokes.length == 1) bonus += 80;
    if (strokes.length <= 3) bonus += 40;
    var long = 0;
    for (final s in strokes) {
      if (s.length >= 24) long++;
    }
    bonus += long * 20;
    return bonus.clamp(0, 200);
  }

  static int _speedBonus(int time, int limit) {
    if (limit <= 0) return 40;
    final ratio = time / limit;
    if (ratio <= 0.45) return 160;
    if (ratio <= 0.7) return 90;
    if (ratio <= 1) return 40;
    return 0;
  }
}
