import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../app/app_controller.dart';
import '../../../core/analytics/analytics.dart';
import '../../../core/design/colors.dart';
import '../engine/builders.dart';
import '../engine/geometry.dart';
import '../levels/catalog.dart';
import '../models/enums.dart';
import '../models/pattern.dart';
import '../renderers/kolam_painter.dart';
import '../widgets/kolam_canvas.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final store = app.store;
    return Scaffold(
      backgroundColor: AarlaColors.ivory,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          children: [
            Text('Profile', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 8),
            const Text('Aarla Play  ·  Kolam Kraze'),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Progress'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/progress'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('My Kolams'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/my-kolams'),
            ),
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Sound'),
              value: store.soundOn,
              onChanged: (v) async {
                await store.setSound(v);
                app.refresh();
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Music'),
              value: store.musicOn,
              onChanged: (v) async {
                await store.setMusic(v);
                app.refresh();
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Haptics'),
              value: store.hapticsOn,
              onChanged: (v) async {
                await store.setHaptics(v);
                app.refresh();
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Reduced motion'),
              value: store.reducedMotion,
              onChanged: (v) async {
                await store.setReducedMotion(v);
                app.refresh();
              },
            ),
            const Divider(),
            TextFormField(
              initialValue: store.displayName,
              decoration: const InputDecoration(labelText: 'Display name'),
              onFieldSubmitted: store.setDisplayName,
            ),
            TextFormField(
              initialValue: store.city,
              decoration: const InputDecoration(labelText: 'City'),
              onFieldSubmitted: store.setCity,
            ),
            TextFormField(
              initialValue: store.country,
              decoration: const InputDecoration(labelText: 'Country'),
              onFieldSubmitted: store.setCountry,
            ),
            const SizedBox(height: 18),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Level editor'),
              subtitle: const Text('Author patterns as JSON'),
              onTap: () => context.push('/editor'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Aarla desk'),
              subtitle: const Text('Moderation queue'),
              onTap: () => context.push('/admin'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final progress = app.store.progress;
    final completed = progress.values.where((p) => p.stars > 0).length;
    final total = KolamCatalog.items.length;
    final pct = total == 0 ? 0 : ((completed / total) * 100).round();
    final stars = progress.values.fold<int>(0, (a, b) => a + b.stars);
    final bestAcc = progress.values.fold<int>(0, (a, b) => b.bestAccuracy > a ? b.bestAccuracy : a);
    final times = progress.values.where((p) => p.bestTime > 0).map((p) => p.bestTime);
    final avg = times.isEmpty ? 0 : (times.reduce((a, b) => a + b) / times.length).round();

    return Scaffold(
      backgroundColor: AarlaColors.ivory,
      appBar: AppBar(title: const Text('Progress')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Center(
            child: SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: pct / 100,
                    strokeWidth: 14,
                    color: AarlaColors.oxide,
                    backgroundColor: AarlaColors.ivoryDeep,
                  ),
                  Text('$pct%', style: Theme.of(context).textTheme.headlineMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(child: Text('Completed')),
          const SizedBox(height: 18),
          _Stat('Levels completed', '$completed / $total'),
          _Stat('Stars collected', '$stars'),
          _Stat('Best accuracy', '$bestAcc%'),
          _Stat('Average time', '${avg}s'),
          _Stat('Longest streak', '${app.store.streak} days'),
          const SizedBox(height: 16),
          const Text('Recent achievements', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          if (completed >= 1) const ListTile(leading: Icon(Icons.auto_awesome, color: AarlaColors.turmeric), title: Text('First kolam')),
          if (stars >= 9) const ListTile(leading: Icon(Icons.star, color: AarlaColors.turmeric), title: Text('Nine stars')),
          if (app.store.streak >= 3) const ListTile(leading: Icon(Icons.wb_sunny_outlined, color: AarlaColors.oxide), title: Text('Three quiet mornings')),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class MyKolamsScreen extends StatefulWidget {
  const MyKolamsScreen({super.key});

  @override
  State<MyKolamsScreen> createState() => _MyKolamsScreenState();
}

class _MyKolamsScreenState extends State<MyKolamsScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    var items = KolamCatalog.items;
    if (_filter == 'completed') {
      items = items.where((i) => (app.store.progress[i.pattern.id]?.stars ?? 0) > 0).toList();
    } else if (_filter == 'favourites') {
      items = items.where((i) => app.store.progress[i.pattern.id]?.favourite == true).toList();
    }
    return Scaffold(
      backgroundColor: AarlaColors.ivory,
      appBar: AppBar(title: const Text('My Kolams')),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final f in ['all', 'completed', 'favourites'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f.toUpperCase()),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'No kolams yet.\nUpload the six 3×3 references and we will match each one.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, height: 1.4),
                      ),
                    ),
                  )
                : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.62, mainAxisSpacing: 12, crossAxisSpacing: 12),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                final p = app.store.progress[item.pattern.id];
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: KolamThumb(pattern: item.pattern, material: app.material, kaavi: app.kaavi)),
                      Text(item.pattern.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                      Row(
                        children: [
                          Text('★' * (p?.stars ?? 0)),
                          const Spacer(),
                          IconButton(
                            icon: Icon(p?.favourite == true ? Icons.favorite : Icons.favorite_border, color: AarlaColors.oxide, size: 20),
                            onPressed: () async {
                              await app.store.toggleFavourite(item.pattern.id);
                              app.refresh();
                            },
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 4,
                        children: [
                          TextButton(onPressed: () { app.selectLevel(item.pattern.id); context.push('/play/material'); }, child: const Text('Replay')),
                          TextButton(onPressed: () { app.selectLevel(item.pattern.id); context.push('/ar'); }, child: const Text('AR')),
                          TextButton(onPressed: () { app.selectLevel(item.pattern.id); context.push('/irl'); }, child: const Text('IRL')),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SubmitScreen extends StatefulWidget {
  const SubmitScreen({super.key});

  @override
  State<SubmitScreen> createState() => _SubmitScreenState();
}

class _SubmitScreenState extends State<SubmitScreen> {
  final _name = TextEditingController();
  final _city = TextEditingController();
  final _country = TextEditingController();
  final _caption = TextEditingController();
  final _ig = TextEditingController();
  String _kind = 'irl';
  bool _consent = false;
  bool _seeded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    _seeded = true;
    Analytics.instance.submissionStarted();
    final store = AppScope.of(context).store;
    _name.text = store.displayName;
    _city.text = store.city;
    _country.text = store.country;
  }

  @override
  void dispose() {
    _name.dispose();
    _city.dispose();
    _country.dispose();
    _caption.dispose();
    _ig.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_consent) return;
    final app = AppScope.of(context);
    await app.store.setDisplayName(_name.text);
    await app.store.setCity(_city.text);
    await app.store.setCountry(_country.text);
    await app.store.addSubmission({
      'id': const Uuid().v4(),
      'displayName': _name.text.trim(),
      'city': _city.text.trim(),
      'country': _country.text.trim(),
      'caption': _caption.text.trim(),
      'instagram': _ig.text.trim(),
      'kind': _kind,
      'material': app.material.name,
      'patternId': app.patternId,
      'consent': true,
      'status': 'pending',
      'featured': false,
      'social': false,
      'createdAt': DateTime.now().toIso8601String(),
    });
    Analytics.instance.submissionCompleted();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sent to the Aarla desk. Nothing publishes automatically.')));
    context.go('/world');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AarlaColors.ivory,
      appBar: AppBar(title: const Text('Share with the world')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          const Text('Wherever you are, you can connect to the culture.', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Display name')),
          TextField(controller: _city, decoration: const InputDecoration(labelText: 'City')),
          TextField(controller: _country, decoration: const InputDecoration(labelText: 'Country')),
          TextField(controller: _caption, decoration: const InputDecoration(labelText: 'Caption (optional)')),
          TextField(controller: _ig, decoration: const InputDecoration(labelText: 'Instagram (optional)')),
          const SizedBox(height: 16),
          const Text('How did you create this?', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(label: const Text('Drawn IRL'), selected: _kind == 'irl', onSelected: (_) => setState(() => _kind = 'irl')),
              ChoiceChip(label: const Text('Placed in AR'), selected: _kind == 'ar', onSelected: (_) => setState(() => _kind = 'ar')),
            ],
          ),
          CheckboxListTile(
            value: _consent,
            onChanged: (v) => setState(() => _consent = v ?? false),
            title: const Text('I allow Aarla to feature this submission in the Aarla app, website and Aarla social channels.'),
          ),
          const SizedBox(height: 12),
          AarlaButton(label: 'SUBMIT', onTap: _consent ? _submit : null),
        ],
      ),
    );
  }
}

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final items = app.store.submissions;
    return Scaffold(
      backgroundColor: AarlaColors.ivory,
      appBar: AppBar(title: const Text('Aarla desk')),
      body: items.isEmpty
          ? const Center(child: Text('Moderation queue is empty.'))
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, i) {
                final s = items[i];
                return Card(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${s['displayName']}  ·  ${s['city']}, ${s['country']}', style: const TextStyle(fontWeight: FontWeight.w800)),
                        Text('${s['kind']}  ·  ${s['material']}  ·  ${s['status']}'),
                        if ((s['caption'] as String?)?.isNotEmpty == true) Text(s['caption'] as String),
                        Text('IG: ${s['instagram'] ?? '—'}  ·  consent ${s['consent']}'),
                        Wrap(
                          spacing: 8,
                          children: [
                            TextButton(onPressed: () => app.store.updateSubmission(s['id'] as String, {'status': 'approved'}).then((_) => app.refresh()), child: const Text('Approve')),
                            TextButton(onPressed: () => app.store.updateSubmission(s['id'] as String, {'status': 'rejected'}).then((_) => app.refresh()), child: const Text('Reject')),
                            TextButton(onPressed: () => app.store.updateSubmission(s['id'] as String, {'featured': true, 'status': 'approved'}).then((_) => app.refresh()), child: const Text('Feature')),
                            TextButton(onPressed: () => app.store.updateSubmission(s['id'] as String, {'social': true, 'socialBucket': 'Daily Feature'}).then((_) => app.refresh()), child: const Text('Social')),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  int _size = 5;
  int _difficulty = 3;
  double _preview = 3;
  int _time = 70;
  String _id = 'kolam_5x5_custom';
  List<List<GPoint>> _paths = [];
  List<Offset> _live = [];
  Size _canvas = const Size(360, 360);

  KolamPattern get _pattern => kolam(
        id: _id,
        name: _id,
        rows: _size,
        difficulty: _difficulty,
        previewSeconds: _preview,
        timeLimitSeconds: _time,
        strokes: strokesFrom(_paths.isEmpty ? [loopAround(GPoint((_size - 1) / 2, (_size - 1) / 2))] : _paths),
      );

  String get _json {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(_pattern.toJson());
  }

  void _commitLive() {
    if (_live.length < 4) {
      setState(() => _live = []);
      return;
    }
    final layout = GridLayout.fromSize(_size, _size, _canvas);
    final pts = <GPoint>[];
    for (final o in _live) {
      final g = layout.toGrid(o);
      final snapped = GPoint((g.x * 2).round() / 2, (g.y * 2).round() / 2);
      if (pts.isEmpty || pts.last != snapped) pts.add(snapped);
    }
    setState(() {
      _paths = [..._paths, pts];
      _live = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AarlaColors.ivory,
      appBar: AppBar(
        title: const Text('Level editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _json));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('JSON copied')));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            children: [3, 4, 5, 7, 9, 11, 13, 15].map((s) {
              return ChoiceChip(label: Text('$s×$s'), selected: _size == s, onSelected: (_) => setState(() { _size = s; _id = 'kolam_${s}x${s}_custom'; _paths = []; }));
            }).toList(),
          ),
          TextField(decoration: const InputDecoration(labelText: 'ID'), controller: TextEditingController(text: _id), onSubmitted: (v) => setState(() => _id = v)),
          Row(children: [
            const Text('Difficulty'),
            Expanded(child: Slider(value: _difficulty.toDouble(), min: 1, max: 8, divisions: 7, onChanged: (v) => setState(() => _difficulty = v.round()))),
            Text('$_difficulty'),
          ]),
          Row(children: [
            const Text('Preview'),
            Expanded(child: Slider(value: _preview, min: 1, max: 6, divisions: 10, onChanged: (v) => setState(() => _preview = v))),
            Text('${_preview.toStringAsFixed(1)}s'),
          ]),
          Row(children: [
            const Text('Time'),
            Expanded(child: Slider(value: _time.toDouble(), min: 20, max: 180, divisions: 16, onChanged: (v) => setState(() => _time = v.round()))),
            Text('${_time}s'),
          ]),
          const SizedBox(height: 8),
          SizedBox(
            height: 360,
            child: LayoutBuilder(
              builder: (context, c) {
                _canvas = Size(c.maxWidth, c.maxHeight);
                return GestureDetector(
                  onPanStart: (d) => setState(() => _live = [d.localPosition]),
                  onPanUpdate: (d) => setState(() => _live = [..._live, d.localPosition]),
                  onPanEnd: (_) => _commitLive(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CustomPaint(
                      size: _canvas,
                      painter: KolamPainter(
                        pattern: _pattern,
                        material: KolamMaterial.kolaMaavu,
                        kaavi: false,
                        showPattern: true,
                        liveStroke: _live,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              TextButton(onPressed: _paths.isEmpty ? null : () => setState(() => _paths.removeLast()), child: const Text('Delete last')),
              TextButton(onPressed: () => setState(() => _paths = []), child: const Text('Clear')),
            ],
          ),
          const Text('Export JSON', style: TextStyle(fontWeight: FontWeight.w800)),
          SelectableText(_json, style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
        ],
      ),
    );
  }
}
