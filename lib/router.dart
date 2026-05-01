import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/models/game_config_model.dart';
import 'features/daily/daily_screen.dart';
import 'features/duel/create_duel_screen.dart';
import 'features/duel/duel_game_screen.dart';
import 'features/duel/duel_home_screen.dart';
import 'features/duel/join_duel_screen.dart';
import 'features/game/game_screen.dart';
import 'features/classic/classic_create_screen.dart';
import 'features/classic/classic_home_screen.dart';
import 'features/classic/classic_join_screen.dart';
import 'features/classic/classic_online_game_screen.dart';
import 'features/home/home_screen.dart';
import 'features/practice/practice_setup_screen.dart';
import 'features/puzzles/puzzle_pack_screen.dart';
import 'features/puzzles/puzzles_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/stats/stats_screen.dart';

// Smooth slide transition for all routes
CustomTransitionPage<T> _slidePage<T>(
    BuildContext context, GoRouterState state, Widget child) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      final fadeTween = Tween<double>(begin: 0.0, end: 1.0)
          .chain(CurveTween(curve: Curves.easeOut));
      return FadeTransition(
        opacity: animation.drive(fadeTween),
        child: SlideTransition(
          position: animation.drive(tween),
          child: child,
        ),
      );
    },
  );
}

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (c, s) => _slidePage(c, s, const HomeScreen()),
    ),
    GoRoute(
      path: '/daily',
      pageBuilder: (c, s) => _slidePage(c, s, const DailyScreen()),
      routes: [
        GoRoute(
          path: 'game',
          pageBuilder: (c, s) {
            final config = s.extra as GameConfig?;
            if (config == null) return _slidePage(c, s, const DailyScreen());
            return _slidePage(c, s, GameScreen(config: config));
          },
        ),
      ],
    ),
    GoRoute(
      path: '/practice',
      pageBuilder: (c, s) => _slidePage(c, s, const PracticeSetupScreen()),
      routes: [
        GoRoute(
          path: 'game',
          pageBuilder: (c, s) {
            final config = s.extra as GameConfig?;
            if (config == null) return _slidePage(c, s, const PracticeSetupScreen());
            return _slidePage(c, s, GameScreen(config: config));
          },
        ),
      ],
    ),
    GoRoute(
      path: '/puzzles',
      pageBuilder: (c, s) => _slidePage(c, s, const PuzzlesScreen()),
      routes: [
        GoRoute(
          path: ':packId',
          pageBuilder: (c, s) => _slidePage(
            c,
            s,
            PuzzlePackScreen(packId: s.pathParameters['packId']!),
          ),
          routes: [
            GoRoute(
              path: 'play',
              pageBuilder: (c, s) {
                final config = s.extra as GameConfig?;
                if (config == null) return _slidePage(c, s, const PuzzlesScreen());
                return _slidePage(c, s, GameScreen(config: config));
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/duel',
      pageBuilder: (c, s) => _slidePage(c, s, const DuelHomeScreen()),
      routes: [
        GoRoute(
          path: 'create',
          pageBuilder: (c, s) => _slidePage(c, s, const CreateDuelScreen()),
        ),
        GoRoute(
          path: 'join',
          pageBuilder: (c, s) => _slidePage(c, s, const JoinDuelScreen()),
        ),
        GoRoute(
          path: 'game/:duelId',
          pageBuilder: (c, s) => _slidePage(
            c,
            s,
            DuelGameScreen(
              duelId: s.pathParameters['duelId']!,
              isHost: s.uri.queryParameters['isHost'] == 'true',
            ),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/classic',
      pageBuilder: (c, s) => _slidePage(c, s, const ClassicHomeScreen()),
      routes: [
        GoRoute(
          path: 'game',
          pageBuilder: (c, s) {
            final config = s.extra as GameConfig?;
            if (config == null) return _slidePage(c, s, const ClassicHomeScreen());
            return _slidePage(c, s, GameScreen(config: config));
          },
        ),
        GoRoute(
          path: 'online',
          redirect: (_, __) => '/classic',
          routes: [
            GoRoute(
              path: 'create',
              pageBuilder: (c, s) {
                final length =
                    int.tryParse(s.uri.queryParameters['length'] ?? '5') ?? 5;
                return _slidePage(
                    c, s, ClassicCreateScreen(initialLength: length));
              },
            ),
            GoRoute(
              path: 'join',
              pageBuilder: (c, s) =>
                  _slidePage(c, s, const ClassicJoinScreen()),
            ),
            GoRoute(
              path: 'game/:duelId',
              pageBuilder: (c, s) => _slidePage(
                c,
                s,
                ClassicOnlineGameScreen(
                  duelId: s.pathParameters['duelId']!,
                  isHost: s.uri.queryParameters['isHost'] == 'true',
                ),
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/stats',
      pageBuilder: (c, s) => _slidePage(c, s, const StatsScreen()),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (c, s) => _slidePage(c, s, const SettingsScreen()),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(
        'Page not found: ${state.uri}',
        style: const TextStyle(color: Colors.white),
      ),
    ),
  ),
);
