import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/models/game_config_model.dart';
import 'features/daily/daily_screen.dart';
import 'features/duel/create_duel_screen.dart';
import 'features/duel/duel_game_screen.dart';
import 'features/duel/duel_home_screen.dart';
import 'features/duel/join_duel_screen.dart';
import 'features/game/game_screen.dart';
import 'features/home/home_screen.dart';
import 'features/practice/practice_setup_screen.dart';
import 'features/puzzles/puzzle_pack_screen.dart';
import 'features/puzzles/puzzles_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/stats/stats_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const HomeScreen(),
    ),
    GoRoute(
      path: '/daily',
      builder: (_, __) => const DailyScreen(),
      routes: [
        GoRoute(
          path: 'game',
          builder: (context, state) {
            final config = state.extra as GameConfig;
            return GameScreen(config: config);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/practice',
      builder: (_, __) => const PracticeSetupScreen(),
      routes: [
        GoRoute(
          path: 'game',
          builder: (context, state) {
            final config = state.extra as GameConfig;
            return GameScreen(config: config);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/puzzles',
      builder: (_, __) => const PuzzlesScreen(),
      routes: [
        GoRoute(
          path: ':packId',
          builder: (context, state) {
            final packId = state.pathParameters['packId']!;
            return PuzzlePackScreen(packId: packId);
          },
          routes: [
            GoRoute(
              path: 'play',
              builder: (context, state) {
                final config = state.extra as GameConfig;
                return GameScreen(config: config);
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/duel',
      builder: (_, __) => const DuelHomeScreen(),
      routes: [
        GoRoute(
          path: 'create',
          builder: (_, __) => const CreateDuelScreen(),
        ),
        GoRoute(
          path: 'join',
          builder: (_, __) => const JoinDuelScreen(),
        ),
        GoRoute(
          path: 'game/:duelId',
          builder: (context, state) {
            final duelId = state.pathParameters['duelId']!;
            final isHost =
                state.uri.queryParameters['isHost'] == 'true';
            return DuelGameScreen(duelId: duelId, isHost: isHost);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/stats',
      builder: (_, __) => const StatsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (_, __) => const SettingsScreen(),
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
