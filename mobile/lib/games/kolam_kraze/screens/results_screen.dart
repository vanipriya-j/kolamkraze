import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_controller.dart';
import '../../../core/analytics/analytics.dart';
import '../../../core/design/colors.dart';
import '../engine/kolam_flame.dart';
import '../levels/catalog.dart';
import '../widgets/kolam_canvas.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  String _clock(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final r = (s % 60).toString().padLeft(2, '0');
    return '$m:$r';
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final item = KolamCatalog.byId(app.patternId);
    final score = app.lastScore;
    final stars = score?.stars ?? 0;
    final offerBreak = app.store.levelsSinceBreak >= 3;

    return Scaffold(
      backgroundColor: AarlaColors.ivory,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          children: [
            Text('KOLAM COMPLETE', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(item.pattern.name, style: TextStyle(color: AarlaColors.charcoal.withValues(alpha: 0.65))),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: KolamDrawView(
                  pattern: item.pattern,
                  material: app.material,
                  kaavi: app.kaavi,
                  instant: app.store.reducedMotion,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '★' * stars + '☆' * (3 - stars),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, color: AarlaColors.turmeric),
            ),
            const SizedBox(height: 12),
            _Metric('Accuracy', '${score?.accuracy ?? 0}%'),
            _Metric('Time', _clock(score?.timeSeconds ?? 0)),
            _Metric('Mistakes', '${score?.mistakes ?? 0}'),
            _Metric('Flow bonus', '+${score?.flowBonus ?? 0}'),
            _Metric('Score', '${score?.score ?? 0}'),
            if (offerBreak) ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AarlaColors.turmeric.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Beautiful work.', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                    const Text('Want to try this one outside?'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: AarlaButton(label: 'DRAW IRL', onTap: () => context.push('/irl'))),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AarlaButton(
                            label: 'ONE MORE',
                            filled: false,
                            onTap: () async {
                              await app.store.resetBreakCounter();
                              if (!context.mounted) return;
                              _next(context, app, item);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            AarlaButton(label: 'NEXT', onTap: () => _next(context, app, item)),
            const SizedBox(height: 10),
            AarlaButton(label: 'REPLAY', filled: false, onTap: () => context.go('/play/game')),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: AarlaButton(label: 'VIEW IN AR', filled: false, onTap: () => context.push('/ar'))),
                const SizedBox(width: 8),
                Expanded(child: AarlaButton(label: 'DRAW IRL', filled: false, onTap: () => context.push('/irl'))),
              ],
            ),
            const SizedBox(height: 10),
            AarlaButton(
              label: 'SHARE',
              filled: false,
              onTap: () {
                Analytics.instance.shareClicked();
                Clipboard.setData(ClipboardData(
                  text: 'I just drew ${item.pattern.name} in Kolam Kraze — ${score?.stars ?? 0} stars.',
                ));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied a note to share.')));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _next(BuildContext context, AppController app, CatalogItem item) {
    final i = KolamCatalog.items.indexWhere((e) => e.pattern.id == item.pattern.id);
    final next = KolamCatalog.items[(i + 1) % KolamCatalog.items.length];
    app.selectLevel(next.pattern.id, dailyPlay: false);
    context.go('/play/material');
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: AarlaColors.charcoal.withValues(alpha: 0.6))),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        ],
      ),
    );
  }
}
