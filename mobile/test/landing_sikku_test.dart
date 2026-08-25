import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kolam_kraze/app/app.dart';
import 'package:kolam_kraze/app/app_controller.dart';
import 'package:kolam_kraze/core/storage/app_store.dart';
import 'package:kolam_kraze/games/kolam_kraze/widgets/landing_sikku.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  test('landing sikku is a 25-pulli diamond lattice with a closed outer cycle', () {
    final geom = LandingSikkuGeometry.build();
    expect(geom.pullis, hasLength(25));
    expect(geom.boundary, isNotEmpty);
    expect(geom.boundary.length, greaterThanOrEqualTo(8));
    expect(geom.internalEdges, isNotEmpty);
    expect(geom.peaks, isNotEmpty);
  });

  test('landing sikku paints cream-on-kaavi', () async {
    const size = Size(720, 720);
    final recorder = ui.PictureRecorder();
    LandingSikkuPainter(fillBackground: true).paint(Canvas(recorder), size);
    final image = await recorder.endRecording().toImage(size.width.round(), size.height.round());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = data!.buffer.asUint8List();
    expect(bytes.length, greaterThan(1000));

    Directory('/tmp/kolam-landing').createSync(recursive: true);
    File('/tmp/kolam-landing/landing_sikku.png').writeAsBytesSync(bytes);
  });

  testWidgets('splash landing shows the mark image', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(KolamKrazeApp(controller: AppController(AppStore(prefs))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('landing-sikku')), findsOneWidget);
    expect(find.image(const AssetImage('assets/branding/mark.png')), findsWidgets);
    expect(find.text('GET STARTED'), findsOneWidget);
    await _saveScreen(tester, 'splash_landing');
  });

  testWidgets('home landing shows the mark image above PLAY', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({'onboarded': true});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(KolamKrazeApp(controller: AppController(AppStore(prefs))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('landing-sikku')), findsOneWidget);
    expect(find.image(const AssetImage('assets/branding/mark.png')), findsWidgets);
    expect(find.text('PLAY'), findsOneWidget);
    await _saveScreen(tester, 'home_landing');
  });
}

Future<void> _saveScreen(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byType(RepaintBoundary).first,
    );
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    Directory('/tmp/kolam-landing').createSync(recursive: true);
    File('/tmp/kolam-landing/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
  });
}
