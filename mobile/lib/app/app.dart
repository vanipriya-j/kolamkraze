import 'package:flutter/material.dart';

import '../core/design/aarla_theme.dart';
import 'app_controller.dart';
import 'router.dart';

class KolamKrazeApp extends StatefulWidget {
  const KolamKrazeApp({super.key, required this.controller});

  final AppController controller;

  @override
  State<KolamKrazeApp> createState() => _KolamKrazeAppState();
}

class _KolamKrazeAppState extends State<KolamKrazeApp> {
  late final router = createRouter(widget.controller);

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: widget.controller,
      child: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          return MaterialApp.router(
            title: 'Aarla Play: Kolam Kraze',
            debugShowCheckedModeBanner: false,
            theme: buildAarlaTheme(),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
