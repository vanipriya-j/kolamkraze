import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/app_controller.dart';
import 'core/analytics/analytics.dart';
import 'core/storage/app_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  final prefs = await SharedPreferences.getInstance();
  final controller = AppController(AppStore(prefs));
  Analytics.instance.appOpened();
  runApp(KolamKrazeApp(controller: controller));
}
