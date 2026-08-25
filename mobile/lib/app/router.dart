import 'package:go_router/go_router.dart';

import '../games/kolam_kraze/screens/bridge_screens.dart';
import '../games/kolam_kraze/screens/home_flow.dart';
import '../games/kolam_kraze/screens/onboarding_screen.dart';
import '../games/kolam_kraze/screens/play_screen.dart';
import '../games/kolam_kraze/screens/profile_flow.dart';
import '../games/kolam_kraze/screens/results_screen.dart';
import 'app_controller.dart';
import 'shell.dart';

GoRouter createRouter(AppController app) {
  return GoRouter(
    initialLocation: app.store.onboarded ? '/home' : '/onboarding',
    routes: [
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (c, s) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/daily', builder: (c, s) => const DailyScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/create', builder: (c, s) => const CreateScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/world', builder: (c, s) => const WorldScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen())]),
        ],
      ),
      GoRoute(path: '/play/mode', builder: (c, s) => const ModeSelectScreen()),
      GoRoute(path: '/play/levels', builder: (c, s) => const LevelSelectScreen()),
      GoRoute(path: '/play/material', builder: (c, s) => const MaterialSelectScreen()),
      GoRoute(path: '/play/game', builder: (c, s) => const PlayScreen()),
      GoRoute(path: '/play/results', builder: (c, s) => const ResultsScreen()),
      GoRoute(path: '/irl', builder: (c, s) => const IrlScreen()),
      GoRoute(path: '/ar', builder: (c, s) => const ArScreen()),
      GoRoute(path: '/my-kolams', builder: (c, s) => const MyKolamsScreen()),
      GoRoute(path: '/progress', builder: (c, s) => const ProgressScreen()),
      GoRoute(path: '/editor', builder: (c, s) => const EditorScreen()),
      GoRoute(path: '/admin', builder: (c, s) => const AdminScreen()),
      GoRoute(path: '/submit', builder: (c, s) => const SubmitScreen()),
    ],
  );
}
