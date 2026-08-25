class Analytics {
  Analytics._();
  static final Analytics instance = Analytics._();

  final List<Map<String, Object?>> events = [];

  void track(String name, [Map<String, Object?> props = const {}]) {
    events.add({'name': name, 'at': DateTime.now().toIso8601String(), ...props});
  }

  void appOpened() => track('app_opened');
  void playStarted() => track('play_started');
  void modeSelected(String mode) => track('mode_selected', {'mode': mode});
  void levelSelected(String id) => track('level_selected', {'id': id});
  void materialSelected(String material) =>
      track('material_selected', {'material': material});
  void kaaviToggled(bool on) => track('kaavi_toggled', {'on': on});
  void previewStarted() => track('preview_started');
  void previewCompleted() => track('preview_completed');
  void strokeStarted() => track('stroke_started');
  void undoUsed() => track('undo_used');
  void peekUsed() => track('peek_used');
  void levelCompleted(String id, int stars) =>
      track('level_completed', {'id': id, 'stars': stars});
  void levelFailed(String id) => track('level_failed', {'id': id});
  void levelRetried(String id) => track('level_retried', {'id': id});
  void dailyStarted() => track('daily_started');
  void dailyCompleted() => track('daily_completed');
  void drawIrlOpened() => track('draw_irl_opened');
  void irlPhotoAdded() => track('irl_photo_added');
  void arOpened() => track('ar_opened');
  void arPlaced() => track('ar_placed');
  void arRecordStarted() => track('ar_record_started');
  void arRecordCompleted() => track('ar_record_completed');
  void worldOpened() => track('world_opened');
  void submissionStarted() => track('submission_started');
  void submissionCompleted() => track('submission_completed');
  void shareClicked() => track('share_clicked');
  void sessionCompleted() => track('session_completed');
}
