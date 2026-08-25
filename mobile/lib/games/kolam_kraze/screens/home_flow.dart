import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_controller.dart';
import '../../../core/design/assets.dart';
import '../../../core/design/colors.dart';
import '../levels/catalog.dart';
import '../models/enums.dart';
import '../widgets/kolam_canvas.dart';
import '../widgets/landing_sikku.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final daily = KolamCatalog.dailyFor(DateTime.now());
    final todayKey = '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
    final done = app.store.lastDailyKey == todayKey;

    return Scaffold(
      backgroundColor: AarlaColors.maroonDeep,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            const Text('AARLA PLAY', style: TextStyle(color: AarlaColors.turmeric, letterSpacing: 2.4, fontWeight: FontWeight.w700, fontSize: 11)),
            const SizedBox(height: 6),
            Text('Kolam Kraze', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AarlaColors.ivory)),
            const SizedBox(height: 6),
            Text('Can you reproduce the kolam?', style: TextStyle(color: AarlaColors.ivory.withValues(alpha: 0.72), fontSize: 16)),
            const SizedBox(height: 18),
            Align(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 248, maxHeight: 248),
                child: const LandingMark(key: Key('landing-sikku')),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 132,
              child: FilledButton(
                onPressed: () {
                  AppScope.of(context);
                  context.push('/play/mode');
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AarlaColors.oxide,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                ),
                child: const Text('PLAY', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800, letterSpacing: 4, color: AarlaColors.ivory)),
              ),
            ),
            const SizedBox(height: 22),
            const SectionLabel("Today's Kolam", light: true),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                app.selectLevel(daily.pattern.id, dailyPlay: true);
                context.push('/daily');
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AarlaColors.ivory.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AarlaColors.ivory.withValues(alpha: 0.12)),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 92, child: KolamThumb(pattern: daily.pattern, kaavi: app.kaavi, material: app.material)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(daily.pattern.name, style: const TextStyle(color: AarlaColors.ivory, fontWeight: FontWeight.w800, fontSize: 18)),
                          Text(
                            '${daily.pattern.rows}×${daily.pattern.columns}  ·  ${app.mode.label}',
                            style: TextStyle(color: AarlaColors.ivory.withValues(alpha: 0.7)),
                          ),
                          const SizedBox(height: 10),
                          Text(done ? 'Completed today' : 'Play Now', style: const TextStyle(color: AarlaColors.turmeric, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.55,
              children: [
                _Shortcut('My Kolams', Icons.auto_awesome_mosaic_outlined, () => context.push('/my-kolams')),
                _Shortcut('AR Kolam', Icons.view_in_ar_outlined, () => context.push('/ar')),
                _Shortcut('Progress', Icons.insights_outlined, () => context.push('/progress')),
                _Shortcut('Around the World', Icons.public_outlined, () => context.go('/world')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut(this.label, this.icon, this.onTap);
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AarlaColors.ivory.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AarlaColors.turmeric),
              const Spacer(),
              Text(label, style: const TextStyle(color: AarlaColors.ivory, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class ModeSelectScreen extends StatelessWidget {
  const ModeSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AarlaColors.ivory,
      appBar: AppBar(title: const Text('Choose play mode')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: const [
          _PlayModeCard(PlayMode.memory, AarlaColors.maroon, Icons.psychology_alt_outlined),
          _PlayModeCard(PlayMode.copy, AarlaColors.mutedGreen, Icons.visibility_outlined),
          _PlayModeCard(PlayMode.flash, Color(0xFFC4922A), Icons.flash_on_outlined),
        ],
      ),
    );
  }
}

class _PlayModeCard extends StatelessWidget {
  const _PlayModeCard(this.mode, this.color, this.icon);
  final PlayMode mode;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            AppScope.of(context).selectMode(mode);
            context.push('/play/levels');
          },
          child: SizedBox(
            height: 148,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  Icon(icon, size: 48, color: AarlaColors.ivory),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(mode.label.toUpperCase(), style: const TextStyle(color: AarlaColors.ivory, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                        const SizedBox(height: 6),
                        Text(mode.line, style: const TextStyle(color: Color(0xFFF6E4D4), fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  DifficultyFilter _filter = DifficultyFilter.all;

  bool _unlocked(CatalogItem item) {
    if (item.levelNumber <= 5) return true;
    final prev = KolamCatalog.items[item.levelNumber - 2];
    return (AppScope.of(context).store.progress[prev.pattern.id]?.stars ?? 0) >= 1;
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final items = KolamCatalog.filtered(filter: _filter);
    return Scaffold(
      backgroundColor: AarlaColors.ivory,
      appBar: AppBar(title: Text('${app.mode.label} · Levels')),
      body: Column(
        children: [
          AarlaPills<DifficultyFilter>(
            values: DifficultyFilter.values,
            selected: _filter,
            label: (f) => f.name,
            onSelect: (f) => setState(() => _filter = f),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                final progress = app.store.progress[item.pattern.id];
                final locked = !_unlocked(item);
                return GestureDetector(
                  onTap: locked
                      ? null
                      : () {
                          app.selectLevel(item.pattern.id);
                          context.push('/play/material');
                        },
                  child: Opacity(
                    opacity: locked ? 0.45 : 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [BoxShadow(color: AarlaColors.maroon.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 6))],
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: KolamThumb(pattern: item.pattern, material: app.material, kaavi: false)),
                          const SizedBox(height: 8),
                          Text('Level ${item.levelNumber}', style: const TextStyle(fontWeight: FontWeight.w800)),
                          Text('${item.pattern.rows}×${item.pattern.columns}  ·  ${item.pattern.name}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                          Text(
                            () {
                              final earned = progress?.stars ?? 0;
                              return locked ? 'Locked' : '${'★' * earned}${'☆' * (3 - earned)}';
                            }(),
                            style: const TextStyle(color: AarlaColors.turmeric, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
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

class MaterialSelectScreen extends StatelessWidget {
  const MaterialSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final item = KolamCatalog.byId(app.patternId);
    return Scaffold(
      backgroundColor: AarlaColors.ivory,
      appBar: AppBar(title: const Text('Choose material')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          ...KolamMaterial.values.map(
            (m) => MaterialPreviewCard(
              material: m,
              pattern: item.pattern,
              selected: app.material == m,
              kaavi: app.kaavi,
              onTap: () => app.setMaterial(m),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AarlaColors.kaavi.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: OptionalAssetImage(
                      asset: AarlaAssets.kaavi,
                      fallback: const ColoredBox(color: AarlaColors.kaavi),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Add Kaavi', style: TextStyle(fontWeight: FontWeight.w800)),
                      Text('Brick-red accents & borders'),
                    ],
                  ),
                ),
                Switch(
                  value: app.kaavi,
                  activeThumbColor: AarlaColors.kaavi,
                  onChanged: app.setKaavi,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AarlaButton(
            label: 'BEGIN',
            onTap: () {
              app.haptic();
              context.push('/play/game');
            },
          ),
        ],
      ),
    );
  }
}
