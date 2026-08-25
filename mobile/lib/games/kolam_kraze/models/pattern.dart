import 'dart:math' as math;
import 'package:flutter/foundation.dart';

@immutable
class GPoint {
  const GPoint(this.x, this.y);
  final double x;
  final double y;

  GPoint operator +(GPoint other) => GPoint(x + other.x, y + other.y);
  GPoint operator -(GPoint other) => GPoint(x - other.x, y - other.y);

  double get length => math.sqrt(x * x + y * y);

  GPoint scale(double s) => GPoint(x * s, y * s);

  Map<String, double> toJson() => {'x': x, 'y': y};

  factory GPoint.fromJson(Map<String, dynamic> json) =>
      GPoint((json['x'] as num).toDouble(), (json['y'] as num).toDouble());

  @override
  bool operator ==(Object other) =>
      other is GPoint && (other.x - x).abs() < 0.001 && (other.y - y).abs() < 0.001;

  @override
  int get hashCode => Object.hash(x.toStringAsFixed(2), y.toStringAsFixed(2));
}

class KolamStroke {
  const KolamStroke({
    required this.id,
    required this.points,
    this.closed = true,
    this.kaavi = false,
  });

  final String id;
  final List<GPoint> points;
  final bool closed;
  final bool kaavi;

  Map<String, dynamic> toJson() => {
        'id': id,
        'closed': closed,
        'kaavi': kaavi,
        'points': points.map((p) => p.toJson()).toList(),
      };

  factory KolamStroke.fromJson(Map<String, dynamic> json) => KolamStroke(
        id: json['id'] as String,
        closed: json['closed'] as bool? ?? true,
        kaavi: json['kaavi'] as bool? ?? false,
        points: (json['points'] as List)
            .map((e) => GPoint.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

class KolamPattern {
  const KolamPattern({
    required this.id,
    required this.name,
    required this.rows,
    required this.columns,
    required this.strokes,
    required this.difficulty,
    this.previewSeconds = 6,
    this.timeLimitSeconds = 60,
    this.world = 'first_dots',
    this.culturalNote,
  });

  final String id;
  final String name;
  final int rows;
  final int columns;
  final List<KolamStroke> strokes;
  final int difficulty;
  final double previewSeconds;
  final int timeLimitSeconds;
  final String world;
  final String? culturalNote;

  KolamPattern copyWith({
    String? id,
    String? name,
    int? rows,
    int? columns,
    List<KolamStroke>? strokes,
    int? difficulty,
    double? previewSeconds,
    int? timeLimitSeconds,
    String? world,
    String? culturalNote,
  }) {
    return KolamPattern(
      id: id ?? this.id,
      name: name ?? this.name,
      rows: rows ?? this.rows,
      columns: columns ?? this.columns,
      strokes: strokes ?? this.strokes,
      difficulty: difficulty ?? this.difficulty,
      previewSeconds: previewSeconds ?? this.previewSeconds,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      world: world ?? this.world,
      culturalNote: culturalNote ?? this.culturalNote,
    );
  }

  int get gridSize => rows;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'rows': rows,
        'columns': columns,
        'difficulty': difficulty,
        'previewSeconds': previewSeconds,
        'timeLimitSeconds': timeLimitSeconds,
        'world': world,
        'culturalNote': culturalNote,
        'strokes': strokes.map((s) => s.toJson()).toList(),
      };

  factory KolamPattern.fromJson(Map<String, dynamic> json) => KolamPattern(
        id: json['id'] as String,
        name: json['name'] as String? ?? json['id'] as String,
        rows: json['rows'] as int,
        columns: json['columns'] as int? ?? json['rows'] as int,
        difficulty: json['difficulty'] as int? ?? 1,
        previewSeconds: (json['previewSeconds'] as num?)?.toDouble() ?? 6,
        timeLimitSeconds: json['timeLimitSeconds'] as int? ?? 60,
        world: json['world'] as String? ?? 'first_dots',
        culturalNote: json['culturalNote'] as String?,
        strokes: (json['strokes'] as List)
            .map((e) => KolamStroke.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}
