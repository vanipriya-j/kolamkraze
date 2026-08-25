import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../games/kolam_kraze/models/enums.dart';
import '../../games/kolam_kraze/scoring/scorer.dart';

class LevelProgress {
  const LevelProgress({
    required this.stars,
    required this.bestScore,
    required this.bestAccuracy,
    required this.bestTime,
    this.favourite = false,
    this.lastMaterial,
    this.completedAt,
  });

  final int stars;
  final int bestScore;
  final int bestAccuracy;
  final int bestTime;
  final bool favourite;
  final String? lastMaterial;
  final String? completedAt;

  Map<String, dynamic> toJson() => {
        'stars': stars,
        'bestScore': bestScore,
        'bestAccuracy': bestAccuracy,
        'bestTime': bestTime,
        'favourite': favourite,
        'lastMaterial': lastMaterial,
        'completedAt': completedAt,
      };

  factory LevelProgress.fromJson(Map<String, dynamic> json) => LevelProgress(
        stars: json['stars'] as int? ?? 0,
        bestScore: json['bestScore'] as int? ?? 0,
        bestAccuracy: json['bestAccuracy'] as int? ?? 0,
        bestTime: json['bestTime'] as int? ?? 0,
        favourite: json['favourite'] as bool? ?? false,
        lastMaterial: json['lastMaterial'] as String?,
        completedAt: json['completedAt'] as String?,
      );

  LevelProgress merge(ScoreResult result, KolamMaterial material) {
    return LevelProgress(
      stars: result.stars > stars ? result.stars : stars,
      bestScore: result.score > bestScore ? result.score : bestScore,
      bestAccuracy: result.accuracy > bestAccuracy ? result.accuracy : bestAccuracy,
      bestTime: bestTime == 0 || result.timeSeconds < bestTime ? result.timeSeconds : bestTime,
      favourite: favourite,
      lastMaterial: material.name,
      completedAt: DateTime.now().toIso8601String(),
    );
  }
}

class AppStore {
  AppStore(this._prefs);

  final SharedPreferences _prefs;

  static const _kOnboarded = 'onboarded';
  static const _kMaterial = 'material';
  static const _kKaavi = 'kaavi';
  static const _kSound = 'sound';
  static const _kMusic = 'music';
  static const _kHaptics = 'haptics';
  static const _kReducedMotion = 'reduced_motion';
  static const _kProgress = 'progress';
  static const _kDaily = 'daily';
  static const _kStreak = 'streak';
  static const _kLastPlay = 'last_play';
  static const _kDisplayName = 'display_name';
  static const _kCity = 'city';
  static const _kCountry = 'country';
  static const _kSubmissions = 'submissions';
  static const _kIrlKeepAwake = 'irl_keep_awake';
  static const _kLevelsSinceBreak = 'levels_since_break';

  bool get onboarded => _prefs.getBool(_kOnboarded) ?? false;
  Future<void> setOnboarded() => _prefs.setBool(_kOnboarded, true);

  KolamMaterial get material {
    final raw = _prefs.getString(_kMaterial);
    return KolamMaterial.values.firstWhere(
      (m) => m.name == raw,
      orElse: () => KolamMaterial.kolaMaavu,
    );
  }

  Future<void> setMaterial(KolamMaterial value) =>
      _prefs.setString(_kMaterial, value.name);

  bool get kaavi => _prefs.getBool(_kKaavi) ?? false;
  Future<void> setKaavi(bool value) => _prefs.setBool(_kKaavi, value);

  bool get soundOn => _prefs.getBool(_kSound) ?? true;
  Future<void> setSound(bool value) => _prefs.setBool(_kSound, value);

  bool get musicOn => _prefs.getBool(_kMusic) ?? false;
  Future<void> setMusic(bool value) => _prefs.setBool(_kMusic, value);

  bool get hapticsOn => _prefs.getBool(_kHaptics) ?? true;
  Future<void> setHaptics(bool value) => _prefs.setBool(_kHaptics, value);

  bool get reducedMotion => _prefs.getBool(_kReducedMotion) ?? false;
  Future<void> setReducedMotion(bool value) => _prefs.setBool(_kReducedMotion, value);

  bool get irlKeepAwake => _prefs.getBool(_kIrlKeepAwake) ?? true;
  Future<void> setIrlKeepAwake(bool value) => _prefs.setBool(_kIrlKeepAwake, value);

  String get displayName => _prefs.getString(_kDisplayName) ?? '';
  Future<void> setDisplayName(String value) => _prefs.setString(_kDisplayName, value);

  String get city => _prefs.getString(_kCity) ?? '';
  Future<void> setCity(String value) => _prefs.setString(_kCity, value);

  String get country => _prefs.getString(_kCountry) ?? '';
  Future<void> setCountry(String value) => _prefs.setString(_kCountry, value);

  Map<String, LevelProgress> get progress {
    final raw = _prefs.getString(_kProgress);
    if (raw == null || raw.isEmpty) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, LevelProgress.fromJson(v as Map<String, dynamic>)));
  }

  Future<void> saveProgress(Map<String, LevelProgress> map) async {
    await _prefs.setString(
      _kProgress,
      jsonEncode(map.map((k, v) => MapEntry(k, v.toJson()))),
    );
  }

  Future<LevelProgress> recordResult(String id, ScoreResult result, KolamMaterial material) async {
    final map = progress;
    final current = map[id] ??
        const LevelProgress(stars: 0, bestScore: 0, bestAccuracy: 0, bestTime: 0);
    final next = current.merge(result, material);
    map[id] = next;
    await saveProgress(map);
    await _bumpStreak();
    await _prefs.setInt(_kLevelsSinceBreak, levelsSinceBreak + 1);
    return next;
  }

  Future<void> toggleFavourite(String id) async {
    final map = progress;
    final current = map[id] ??
        const LevelProgress(stars: 0, bestScore: 0, bestAccuracy: 0, bestTime: 0);
    map[id] = LevelProgress(
      stars: current.stars,
      bestScore: current.bestScore,
      bestAccuracy: current.bestAccuracy,
      bestTime: current.bestTime,
      favourite: !current.favourite,
      lastMaterial: current.lastMaterial,
      completedAt: current.completedAt,
    );
    await saveProgress(map);
  }

  String? get lastDailyKey => _prefs.getString(_kDaily);
  Future<void> markDailyDone(String key) => _prefs.setString(_kDaily, key);

  int get streak => _prefs.getInt(_kStreak) ?? 0;
  int get levelsSinceBreak => _prefs.getInt(_kLevelsSinceBreak) ?? 0;
  Future<void> resetBreakCounter() => _prefs.setInt(_kLevelsSinceBreak, 0);

  Future<void> _bumpStreak() async {
    final today = DateTime.now();
    final key = '${today.year}-${today.month}-${today.day}';
    final last = _prefs.getString(_kLastPlay);
    if (last == key) return;
    final yesterday = today.subtract(const Duration(days: 1));
    final yKey = '${yesterday.year}-${yesterday.month}-${yesterday.day}';
    final next = last == yKey ? streak + 1 : 1;
    await _prefs.setInt(_kStreak, next);
    await _prefs.setString(_kLastPlay, key);
  }

  List<Map<String, dynamic>> get submissions {
    final raw = _prefs.getString(_kSubmissions);
    if (raw == null || raw.isEmpty) return [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  Future<void> addSubmission(Map<String, dynamic> submission) async {
    final list = submissions;
    list.insert(0, submission);
    await _prefs.setString(_kSubmissions, jsonEncode(list));
  }

  Future<void> updateSubmission(String id, Map<String, dynamic> patch) async {
    final list = submissions;
    final i = list.indexWhere((s) => s['id'] == id);
    if (i < 0) return;
    list[i] = {...list[i], ...patch};
    await _prefs.setString(_kSubmissions, jsonEncode(list));
  }
}
