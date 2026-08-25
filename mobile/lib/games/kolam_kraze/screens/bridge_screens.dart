import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/app_controller.dart';
import '../../../core/analytics/analytics.dart';
import '../../../core/design/colors.dart';
import '../community/world_feed.dart';
import '../levels/catalog.dart';
import '../models/enums.dart';
import '../widgets/kolam_canvas.dart';

class DailyScreen extends StatelessWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final daily = KolamCatalog.dailyFor(DateTime.now());
    if (daily == null) {
      return Scaffold(
        backgroundColor: AarlaColors.ivory,
        appBar: AppBar(title: const Text("Today's Kolam")),
        body: const Center(child: Text('No kolams yet.')),
      );
    }
    final key = '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
    final done = app.store.lastDailyKey == key;

    return Scaffold(
      backgroundColor: AarlaColors.ivory,
      appBar: AppBar(title: const Text("Today's Kolam")),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          KolamThumb(pattern: daily.pattern, material: app.material, kaavi: app.kaavi),
          const SizedBox(height: 16),
          Text(daily.pattern.name, style: Theme.of(context).textTheme.headlineMedium),
          Text('${daily.pattern.rows}×${daily.pattern.columns}  ·  ${app.mode.label}'),
          if (daily.culturalNote != null) ...[
            const SizedBox(height: 10),
            Text(daily.culturalNote!, style: TextStyle(color: AarlaColors.charcoal.withValues(alpha: 0.7), height: 1.4)),
          ],
          const SizedBox(height: 8),
          const Text('Reward  ·  Daily star + streak', style: TextStyle(color: AarlaColors.oxide, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          AarlaButton(
            label: done ? 'PLAY AGAIN' : "PLAY TODAY'S KOLAM",
            onTap: () {
              Analytics.instance.dailyStarted();
              app.selectMode(PlayMode.memory);
              app.selectLevel(daily.pattern.id, dailyPlay: true);
              context.push('/play/material');
            },
          ),
          const SizedBox(height: 10),
          AarlaButton(
            label: 'PRACTICE',
            filled: false,
            onTap: () {
              app.selectMode(PlayMode.copy);
              app.selectLevel(daily.pattern.id, dailyPlay: false);
              context.push('/play/material');
            },
          ),
        ],
      ),
    );
  }
}

class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AarlaColors.ivory,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 8),
              const Text('Bring a kolam into the room — or onto the floor outside.'),
              const SizedBox(height: 24),
              Expanded(
                child: _CreateCard(
                  title: 'PLACE IN AR',
                  line: 'Bring your kolam into any space.',
                  color: AarlaColors.indigo,
                  onTap: () => context.push('/ar'),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: _CreateCard(
                  title: 'DRAW IRL',
                  line: 'Use the pattern and make it for real.',
                  color: AarlaColors.oxide,
                  onTap: () => context.push('/irl'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateCard extends StatelessWidget {
  const _CreateCard({required this.title, required this.line, required this.color, required this.onTap});
  final String title;
  final String line;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AarlaColors.ivory, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 1)),
              const Spacer(),
              Text(line, style: const TextStyle(color: Color(0xFFF3E6D8), fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}

class IrlScreen extends StatefulWidget {
  const IrlScreen({super.key});

  @override
  State<IrlScreen> createState() => _IrlScreenState();
}

class _IrlScreenState extends State<IrlScreen> {
  String? _photoPath;
  bool _guide = false;

  @override
  void initState() {
    super.initState();
    Analytics.instance.drawIrlOpened();
  }

  Future<void> _photo(ImageSource source) async {
    try {
      final file = await ImagePicker().pickImage(source: source, imageQuality: 85);
      if (file == null) return;
      if (!mounted) return;
      setState(() => _photoPath = file.path);
      AppScope.of(context).lastPhotoPath = file.path;
      Analytics.instance.irlPhotoAdded();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Camera stays on this device until you submit.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final item = KolamCatalog.tryById(app.patternId) ?? CatalogItem(
      pattern: KolamCatalog.placeholder,
      world: PatternWorld.firstDots,
      levelNumber: 0,
    );
    return Scaffold(
      backgroundColor: AarlaColors.charcoal,
      appBar: AppBar(
        backgroundColor: AarlaColors.charcoal,
        foregroundColor: AarlaColors.ivory,
        title: const Text('Draw IRL'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Text(item.pattern.name, style: const TextStyle(color: AarlaColors.ivory, fontSize: 22, fontWeight: FontWeight.w800)),
          Text('${item.pattern.rows}×${item.pattern.columns}', style: TextStyle(color: AarlaColors.ivory.withValues(alpha: 0.7))),
          const SizedBox(height: 12),
          SizedBox(
            height: 420,
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4,
              child: KolamThumb(pattern: item.pattern, material: app.material, kaavi: app.kaavi, showPattern: true),
            ),
          ),
          SwitchListTile(
            title: const Text('Stroke guidance', style: TextStyle(color: AarlaColors.ivory)),
            value: _guide,
            onChanged: (v) => setState(() => _guide = v),
          ),
          SwitchListTile(
            title: const Text('Keep screen awake', style: TextStyle(color: AarlaColors.ivory)),
            value: app.store.irlKeepAwake,
            onChanged: (v) async {
              await app.store.setIrlKeepAwake(v);
              app.refresh();
            },
          ),
          const SizedBox(height: 8),
          AarlaButton(label: 'ADD YOUR PHOTO', onTap: () => _photo(ImageSource.camera), color: AarlaColors.oxide),
          const SizedBox(height: 8),
          AarlaButton(label: 'CHOOSE PHOTO', filled: false, onTap: () => _photo(ImageSource.gallery)),
          if (_photoPath != null) ...[
            const SizedBox(height: 12),
            const Text('Saved on this device.', style: TextStyle(color: AarlaColors.turmeric)),
            AarlaButton(label: 'SHARE WITH THE WORLD', onTap: () => context.push('/submit')),
          ],
        ],
      ),
    );
  }
}

class ArScreen extends StatefulWidget {
  const ArScreen({super.key});

  @override
  State<ArScreen> createState() => _ArScreenState();
}

class _ArScreenState extends State<ArScreen> {
  bool _placed = false;
  bool _locked = false;
  bool _instant = true;
  bool _recording = false;
  bool _captured = false;
  double _scale = 1;
  double _rotation = 0;
  Offset _offset = Offset.zero;
  String _surface = 'floor';

  @override
  void initState() {
    super.initState();
    Analytics.instance.arOpened();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final item = KolamCatalog.tryById(app.patternId) ?? CatalogItem(
      pattern: KolamCatalog.placeholder,
      world: PatternWorld.firstDots,
      levelNumber: 0,
    );
    app.arSurface = _surface;
    app.arInstant = _instant;

    return Scaffold(
      backgroundColor: AarlaColors.slate,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AarlaColors.ivory,
        title: const Text('AR Kolam'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ChoiceChip(label: const Text('Floor'), selected: _surface == 'floor', onSelected: (_) => setState(() => _surface = 'floor')),
                const SizedBox(width: 8),
                ChoiceChip(label: const Text('Wall'), selected: _surface == 'wall', onSelected: (_) => setState(() => _surface = 'wall')),
                const Spacer(),
                Text(_placed ? (_locked ? 'Locked' : 'Placed') : 'Overlay mode', style: const TextStyle(color: AarlaColors.ivory)),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_placed) return;
                setState(() => _placed = true);
                Analytics.instance.arPlaced();
              },
              onPanUpdate: _locked
                  ? null
                  : (d) => setState(() => _offset += d.delta),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(painter: _FloorPainter(wall: _surface == 'wall')),
                  if (!_placed)
                    const Center(
                      child: Text('Point at a surface\nTap to place', textAlign: TextAlign.center, style: TextStyle(color: AarlaColors.ivory, fontSize: 20, fontWeight: FontWeight.w700, height: 1.4)),
                    ),
                  if (_placed)
                    Align(
                      alignment: Alignment.center,
                      child: Transform.translate(
                        offset: _offset,
                        child: Transform.rotate(
                          angle: _rotation,
                          child: Transform.scale(
                            scale: _scale,
                            child: SizedBox(
                              width: 240,
                              height: 240,
                              child: KolamThumb(pattern: item.pattern, material: app.material, kaavi: app.kaavi),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_recording)
                    const Positioned(top: 12, left: 0, right: 0, child: Center(child: Text('REC  00:04', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w800)))),
                ],
              ),
            ),
          ),
          if (_placed && !_captured && !_recording)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                children: [
                  if (!_locked) ...[
                    Row(children: [
                      const Text('Scale', style: TextStyle(color: AarlaColors.ivory)),
                      Expanded(child: Slider(value: _scale, min: 0.5, max: 2.2, onChanged: (v) => setState(() => _scale = v))),
                    ]),
                    Row(children: [
                      const Text('Rotate', style: TextStyle(color: AarlaColors.ivory)),
                      Expanded(child: Slider(value: _rotation, min: -3.14, max: 3.14, onChanged: (v) => setState(() => _rotation = v))),
                    ]),
                  ],
                  Row(
                    children: [
                      TextButton(onPressed: () => setState(() => _instant = true), child: Text('INSTANT', style: TextStyle(color: _instant ? AarlaColors.turmeric : AarlaColors.ivory))),
                      TextButton(onPressed: () => setState(() => _instant = false), child: Text('DRAW', style: TextStyle(color: !_instant ? AarlaColors.turmeric : AarlaColors.ivory))),
                      const Spacer(),
                      TextButton(onPressed: () => setState(() => _locked = !_locked), child: Text(_locked ? 'Unlock' : 'Lock', style: const TextStyle(color: AarlaColors.ivory))),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: AarlaButton(label: 'PHOTO', onTap: () => setState(() => _captured = true))),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AarlaButton(
                          label: 'VIDEO',
                          filled: false,
                          onTap: () async {
                            Analytics.instance.arRecordStarted();
                            setState(() => _recording = true);
                            await Future<void>.delayed(const Duration(seconds: 4));
                            if (!mounted) return;
                            Analytics.instance.arRecordCompleted();
                            setState(() {
                              _recording = false;
                              _captured = true;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (_captured)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                children: [
                  const Text('BEAUTIFUL!', style: TextStyle(color: AarlaColors.turmeric, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  AarlaButton(label: 'SAVE / SHARE', onTap: () => context.push('/submit')),
                  const SizedBox(height: 8),
                  AarlaButton(label: 'DONE', filled: false, onTap: () => context.go('/create')),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _FloorPainter extends CustomPainter {
  _FloorPainter({required this.wall});
  final bool wall;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: wall
              ? const [Color(0xFFD8C4A8), Color(0xFFB89A78)]
              : const [Color(0xFF8A3A2A), Color(0xFF5C241C), Color(0xFF3A1812)],
        ).createShader(rect),
    );
    final grid = Paint()..color = Colors.white.withValues(alpha: 0.08)..strokeWidth = 1;
    for (var i = 0; i < 12; i++) {
      final y = size.height * (0.35 + i * 0.06);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
  }

  @override
  bool shouldRepaint(covariant _FloorPainter old) => old.wall != wall;
}

class WorldScreen extends StatefulWidget {
  const WorldScreen({super.key});

  @override
  State<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends State<WorldScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
    Analytics.instance.worldOpened();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  List<WorldPost> _posts(AppController app) {
    final approved = app.store.submissions
        .where((s) => s['status'] == 'approved')
        .map((s) => WorldPost(
              id: s['id'] as String,
              displayName: s['displayName'] as String? ?? 'Friend',
              city: s['city'] as String? ?? '',
              country: s['country'] as String? ?? '',
              kind: s['kind'] as String? ?? 'irl',
              material: KolamMaterial.values.firstWhere(
                (m) => m.name == s['material'],
                orElse: () => KolamMaterial.kolaMaavu,
              ),
              caption: s['caption'] as String? ?? '',
              featured: s['featured'] == true,
              patternId: s['patternId'] as String? ?? '',
            ));
    return [...approved, ...seededWorld];
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final posts = _posts(app);
    return Scaffold(
      backgroundColor: AarlaColors.ivory,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Text('Kolams Around the World', style: Theme.of(context).textTheme.headlineMedium),
            ),
            TabBar(
              controller: _tabs,
              isScrollable: true,
              labelColor: AarlaColors.maroon,
              tabs: const [
                Tab(text: 'LATEST'),
                Tab(text: 'FEATURED'),
                Tab(text: 'MY CITY'),
                Tab(text: 'IRL'),
                Tab(text: 'AR'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _Feed(posts),
                  _Feed(posts.where((p) => p.featured).toList()),
                  _Feed(posts.where((p) => p.city.toLowerCase() == app.store.city.toLowerCase() && app.store.city.isNotEmpty).toList()),
                  _Feed(posts.where((p) => p.kind == 'irl').toList()),
                  _Feed(posts.where((p) => p.kind == 'ar').toList()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Feed extends StatelessWidget {
  const _Feed(this.posts);
  final List<WorldPost> posts;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const Center(child: Text('Nothing here yet — a short, curated shelf.'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: posts.length,
      itemBuilder: (context, i) {
        final p = posts[i];
        final pattern = KolamCatalog.tryById(p.patternId)?.pattern ?? KolamCatalog.placeholder;
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: KolamThumb(pattern: pattern, material: p.material)),
              const SizedBox(height: 8),
              Text(p.place, style: const TextStyle(fontWeight: FontWeight.w800)),
              Text(p.how, style: const TextStyle(fontSize: 11)),
            ],
          ),
        );
      },
    );
  }
}
