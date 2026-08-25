import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kolam_kraze/app/app.dart';
import 'package:kolam_kraze/app/app_controller.dart';
import 'package:kolam_kraze/core/storage/app_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('onboarding splash offers Get Started', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(KolamKrazeApp(controller: AppController(AppStore(prefs))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('GET STARTED'), findsOneWidget);
    expect(find.textContaining('Kolam Kraze'), findsWidgets);
    expect(find.byKey(const Key('landing-sikku')), findsOneWidget);
  });

  testWidgets('home shows a dominant PLAY action after onboarding', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({'onboarded': true});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(KolamKrazeApp(controller: AppController(AppStore(prefs))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.byKey(const Key('landing-sikku')), findsOneWidget);
    await tester.scrollUntilVisible(find.text("TODAY'S KOLAM"), 200);
    expect(find.text("TODAY'S KOLAM"), findsOneWidget);
  });
}
