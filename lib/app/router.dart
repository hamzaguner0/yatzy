import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yatzy_tr/features/game/presentation/screens/game_screen.dart';
import 'package:yatzy_tr/features/game/presentation/screens/home_screen.dart';
import 'package:yatzy_tr/features/game/presentation/screens/results_screen.dart';
import 'package:yatzy_tr/features/game/presentation/screens/setup_screen.dart';
import 'package:yatzy_tr/features/settings/presentation/screens/how_to_play_screen.dart';
import 'package:yatzy_tr/features/settings/presentation/screens/settings_screen.dart';

/// Route names
class Routes {
  static const String home = '/';
  static const String setup = '/setup';
  static const String game = '/game';
  static const String results = '/results';
  static const String settings = '/settings';
  static const String howToPlay = '/how-to-play';
}

/// Create the app router
GoRouter createRouter() {
  return GoRouter(
    initialLocation: Routes.home,
    routes: [
      GoRoute(
        path: Routes.home,
        name: 'home',
        pageBuilder: (context, state) => const MaterialPage(
          child: HomeScreen(),
        ),
      ),
      GoRoute(
        path: Routes.setup,
        name: 'setup',
        pageBuilder: (context, state) {
          final isSolo = state.uri.queryParameters['solo'] == 'true';
          return MaterialPage(
            child: SetupScreen(isSolo: isSolo),
          );
        },
      ),
      GoRoute(
        path: Routes.game,
        name: 'game',
        pageBuilder: (context, state) => const MaterialPage(
          child: GameScreen(),
        ),
      ),
      GoRoute(
        path: Routes.results,
        name: 'results',
        pageBuilder: (context, state) => const MaterialPage(
          child: ResultsScreen(),
        ),
      ),
      GoRoute(
        path: Routes.settings,
        name: 'settings',
        pageBuilder: (context, state) => const MaterialPage(
          child: SettingsScreen(),
        ),
      ),
      GoRoute(
        path: Routes.howToPlay,
        name: 'howToPlay',
        pageBuilder: (context, state) => const MaterialPage(
          child: HowToPlayScreen(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
}
