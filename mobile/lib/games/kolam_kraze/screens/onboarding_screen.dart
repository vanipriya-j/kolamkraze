import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_controller.dart';
import '../../../core/design/assets.dart';
import '../../../core/design/colors.dart';
import '../models/enums.dart';
import '../widgets/kolam_canvas.dart';
import '../widgets/landing_sikku.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  int _index = 0;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await AppScope.of(context).store.setOnboarded();
    if (!mounted) return;
    context.go('/home');
  }

  void _next() {
    _page.nextPage(duration: const Duration(milliseconds: 380), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _index == 0 ? AarlaColors.kaaviDeep : AarlaColors.ivory,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _page,
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  _Splash(onStart: _next),
                  _Modes(onNext: _next),
                  _Materials(onDone: _finish),
                ],
              ),
            ),
            if (_index > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _index == i ? 18 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _index == i ? AarlaColors.maroon : AarlaColors.maroon.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          const Spacer(flex: 1),
          const Text(
            'AARLA PLAY',
            style: TextStyle(color: AarlaColors.turmeric, letterSpacing: 3, fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Text(
            'Kolam Kraze',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AarlaColors.ivory),
          ),
          const SizedBox(height: 8),
          const Text('Draw. Remember. Celebrate.', style: TextStyle(color: Color(0xFFE9C9B0), fontSize: 18)),
          const SizedBox(height: 16),
          Expanded(
            flex: 5,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final side = constraints.biggest.shortestSide;
                return Center(
                  child: SizedBox(
                    width: side,
                    height: side,
                    child: const LandingSikku(
                      key: Key('landing-sikku'),
                      fillBackground: false,
                      cornerRadius: 0,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          AarlaButton(label: 'GET STARTED', onTap: onStart, color: AarlaColors.oxide),
        ],
      ),
    );
  }
}

class _Modes extends StatelessWidget {
  const _Modes({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Three ways to play', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Can you reproduce the kolam?', style: TextStyle(color: AarlaColors.charcoal, fontSize: 16)),
          const SizedBox(height: 22),
          _ModeCard(mode: PlayMode.memory, color: AarlaColors.maroon, icon: Icons.psychology_alt_outlined),
          _ModeCard(mode: PlayMode.copy, color: AarlaColors.mutedGreen, icon: Icons.visibility_outlined),
          _ModeCard(mode: PlayMode.flash, color: const Color(0xFFC4922A), icon: Icons.flash_on_outlined),
          const Spacer(),
          AarlaButton(label: 'NEXT', onTap: onNext),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({required this.mode, required this.color, required this.icon});
  final PlayMode mode;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: AarlaColors.ivory, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mode.label.toUpperCase(), style: const TextStyle(color: AarlaColors.ivory, fontWeight: FontWeight.w800, letterSpacing: 1)),
                Text(mode.line, style: const TextStyle(color: Color(0xFFF3E6D8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Materials extends StatelessWidget {
  const _Materials({required this.onDone});
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How do you want to draw?', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          const _Mat(KolamMaterial.chalkpiece),
          const _Mat(KolamMaterial.kolaMaavu),
          const _Mat(KolamMaterial.ezhaiKolam),
          const _Mat(KolamMaterial.rangoli),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AarlaColors.kaavi.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AarlaColors.kaavi.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 52,
                    height: 52,
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
                      Text('Kaavi', style: TextStyle(fontWeight: FontWeight.w800, color: AarlaColors.kaavi)),
                      Text('Optional brick-red accents and borders.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          AarlaButton(label: "LET'S PLAY", onTap: onDone, color: AarlaColors.oxide),
        ],
      ),
    );
  }
}

class _Mat extends StatelessWidget {
  const _Mat(this.material);
  final KolamMaterial material;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 44,
              height: 44,
              child: OptionalAssetImage(
                asset: AarlaAssets.material(material),
                fallback: ColoredBox(
                  color: switch (material) {
                    KolamMaterial.chalkpiece => AarlaColors.slate,
                    KolamMaterial.kolaMaavu => AarlaColors.oxide,
                    KolamMaterial.ezhaiKolam => AarlaColors.stone,
                    KolamMaterial.rangoli => AarlaColors.turmeric,
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(material.label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Text(material.description, style: TextStyle(color: AarlaColors.charcoal.withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}
