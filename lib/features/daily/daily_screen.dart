import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_theme.dart';
import '../../core/models/game_config_model.dart';
import '../../core/services/word_service.dart';
import '../../core/widgets/max_width_view.dart';

class DailyScreen extends ConsumerWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final dateStr = DateFormat('EEEE, MMMM d').format(today);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DAILY'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: MaxWidthView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                dateStr,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your length',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Today\'s puzzle — same word for everyone',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),
              ...List.generate(4, (i) {
                final length = i + 3;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _LengthCard(
                    length: length,
                    date: today,
                    delay: i * 80,
                  ),
                );
              }),
              const SizedBox(height: 24),
              _ArchiveSection(today: today),
            ],
          ),
        ),
      ),
    );
  }
}

class _LengthCard extends StatelessWidget {
  final int length;
  final DateTime date;
  final int delay;

  const _LengthCard({
    required this.length,
    required this.date,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1A1A1B),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final word = WordService.getDailyWord(length, date);
          context.push(
            '/daily/game',
            extra: GameConfig(
              mode: GameMode.daily,
              wordLength: length,
              targetWord: word,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3A3A3C)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.correct.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$length',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.correct,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$length-Letter Word',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${_maxGuesses(length)} attempts',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(length, (i) {
                  return Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(right: 3),
                    color: AppColors.emptyBorder,
                  );
                }),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.chevron_right, color: AppColors.correct),
            ],
          ),
        ),
      ),
    )
        .animate(delay: delay.ms)
        .fade(duration: 300.ms)
        .slideX(begin: 0.1, end: 0, duration: 300.ms);
  }

  int _maxGuesses(int length) {
    switch (length) {
      case 3:
        return 6;
      case 4:
        return 7;
      case 5:
        return 8;
      case 6:
        return 9;
      default:
        return 6;
    }
  }
}

class _ArchiveSection extends StatelessWidget {
  final DateTime today;

  const _ArchiveSection({required this.today});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Archive',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.present.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Last 4 days free',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.present,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(4, (i) {
          final date = today.subtract(Duration(days: i + 1));
          final dateLabel = DateFormat('EEEE, MMM d').format(date);
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today,
                color: AppColors.present, size: 20),
            title: Text(
              dateLabel,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
            trailing:
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            onTap: () {
              // Default to 5-letter for archive
              final word = WordService.getDailyWord(5, date);
              context.push(
                '/daily/game',
                extra: GameConfig(
                  mode: GameMode.daily,
                  wordLength: 5,
                  targetWord: word,
                ),
              );
            },
          );
        }),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.lock, color: Colors.grey, size: 20),
          title: Text(
            'Full archive',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.premium.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'PREMIUM',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.premium,
              ),
            ),
          ),
          onTap: () {},
        ),
      ],
    );
  }
}
