import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../games/kolam_kraze/models/enums.dart';
import '../../games/kolam_kraze/scoring/scorer.dart';
import '../core/analytics/analytics.dart';
import '../core/storage/app_store.dart';

class AppController extends ChangeNotifier {
  AppController(this.store);

  final AppStore store;

  PlayMode mode = PlayMode.memory;
  String patternId = '';
  bool daily = false;
  ScoreResult? lastScore;
  List<List<Offset>> lastStrokes = const [];
  Size lastCanvas = const Size(400, 400);
  String? lastPhotoPath;
  String arSurface = 'floor';
  bool arInstant = false;

  KolamMaterial get material => store.material;
  bool get kaavi => store.kaavi;

  Future<void> setMaterial(KolamMaterial value) async {
    await store.setMaterial(value);
    Analytics.instance.materialSelected(value.name);
    notifyListeners();
  }

  Future<void> setKaavi(bool value) async {
    await store.setKaavi(value);
    Analytics.instance.kaaviToggled(value);
    notifyListeners();
  }

  void selectMode(PlayMode value) {
    mode = value;
    Analytics.instance.modeSelected(value.name);
    notifyListeners();
  }

  void selectLevel(String id, {bool dailyPlay = false}) {
    patternId = id;
    daily = dailyPlay;
    Analytics.instance.levelSelected(id);
    notifyListeners();
  }

  Future<void> recordResult(ScoreResult result, List<List<Offset>> strokes, Size canvas) async {
    lastScore = result;
    lastStrokes = strokes;
    lastCanvas = canvas;
    await store.recordResult(patternId, result, material);
    Analytics.instance.levelCompleted(patternId, result.stars);
    if (daily) {
      final now = DateTime.now();
      await store.markDailyDone('${now.year}-${now.month}-${now.day}');
      Analytics.instance.dailyCompleted();
    }
    Analytics.instance.sessionCompleted();
    notifyListeners();
  }

  Future<void> refresh() async {
    notifyListeners();
  }

  void haptic() {
    if (store.hapticsOn) {
      HapticFeedback.selectionClick();
    }
  }
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!.notifier!;
  }
}
