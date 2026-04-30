import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';
import '../../core/models/user_stats_model.dart';
import '../../core/providers/stats_provider.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _lengths = [3, 4, 5, 6];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this, initialIndex: 2);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(userStatsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('STATS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabs,
          tabs: _lengths
              .map((l) => Tab(text: '${l}L'))
              .toList(),
          labelColor: AppColors.correct,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.correct,
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: _lengths.map((length) {
          final s = stats.forLength(length);
          return _StatsView(stats: s, wordLength: length);
        }).toList(),
      ),
    );
  }
}

class _StatsView extends StatelessWidget {
  final WordLengthStats stats;
  final int wordLength;

  const _StatsView({required this.stats, required this.wordLength});

  @override
  Widget build(BuildContext context) {
    final maxGuesses = wordLength == 3
        ? 6
        : wordLength == 4
            ? 7
            : wordLength == 5
                ? 8
                : 9;

    if (stats.gamesPlayed == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📊', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'No games yet',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Play some $wordLength-letter games to see stats here',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Summary stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatBox(value: '${stats.gamesPlayed}', label: 'Played'),
              _StatBox(
                  value: '${stats.winRate.round()}%', label: 'Win Rate'),
              _StatBox(
                  value: '${stats.currentStreak}', label: 'Streak'),
              _StatBox(
                  value: '${stats.maxStreak}', label: 'Best Streak'),
            ],
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'GUESS DISTRIBUTION',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey[500],
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _DistributionChart(
            distribution: stats.guessDistribution,
            maxGuesses: maxGuesses,
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;

  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
        ),
      ],
    );
  }
}

class _DistributionChart extends StatelessWidget {
  final Map<int, int> distribution;
  final int maxGuesses;

  const _DistributionChart(
      {required this.distribution, required this.maxGuesses});

  @override
  Widget build(BuildContext context) {
    final maxCount = distribution.values.isEmpty
        ? 1
        : distribution.values.reduce((a, b) => a > b ? a : b);

    return Column(
      children: List.generate(maxGuesses, (i) {
        final guess = i + 1;
        final count = distribution[guess] ?? 0;
        final barWidth = maxCount == 0
            ? 0.0
            : (count / maxCount) * (MediaQuery.of(context).size.width - 120);

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                child: Text(
                  '$guess',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[400]),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                width: count == 0 ? 30 : barWidth.clamp(30, double.infinity),
                height: 28,
                color: count == 0 ? const Color(0xFF3A3A3C) : AppColors.correct,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '$count',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
