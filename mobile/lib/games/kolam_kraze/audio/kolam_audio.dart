import 'package:flutter/services.dart';

import '../models/enums.dart';

class KolamAudio {
  KolamAudio._();
  static final KolamAudio instance = KolamAudio._();

  bool soundOn = true;
  bool hapticsOn = true;

  void stroke(KolamMaterial material) {
    if (hapticsOn) HapticFeedback.selectionClick();
    if (!soundOn) return;
    SystemSound.play(SystemSoundType.click);
  }

  void complete() {
    if (hapticsOn) HapticFeedback.mediumImpact();
  }

  void peek() {
    if (hapticsOn) HapticFeedback.lightImpact();
  }
}
