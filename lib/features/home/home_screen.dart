import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';
import '../../core/widgets/max_width_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: MaxWidthView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              // Logo / wordmark
              Text(
                'WORD',
                style: GoogleFonts.inter(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 10,
                ),
              )
                  .animate()
                  .fade(duration: 500.ms)
                  .slideY(begin: -0.3, end: 0, duration: 500.ms),
              _ColoredMark()
                  .animate(delay: 150.ms)
                  .fade(duration: 400.ms),
              const SizedBox(height: 52),

              // Mode cards
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _ModeCard(
                      icon: '📅',
                      title: 'Daily Challenge',
                      subtitle: 'One word per day · Same for everyone',
                      color: AppColors.correct,
                      delay: 80,
                      onTap: () => context.push('/daily'),
                    ),
                    const SizedBox(height: 14),
                    _ModeCard(
                      icon: '🎯',
                      title: 'Practice',
                      subtitle: 'Unlimited games · Random words',
                      color: AppColors.present,
                      delay: 160,
                      onTap: () => context.push('/practice'),
                    ),
                    const SizedBox(height: 14),
                    _ModeCard(
                      icon: '🧩',
                      title: 'Puzzles',
                      subtitle: 'Themed packs · 5 free per pack',
                      color: const Color(0xFF6B5CE7),
                      delay: 240,
                      onTap: () => context.push('/puzzles'),
                    ),
                    const SizedBox(height: 14),
                    _ModeCard(
                      icon: '⚔️',
                      title: 'Duel a Friend',
                      subtitle: 'Real-time · See their tiles live',
                      color: const Color(0xFFE74C3C),
                      delay: 320,
                      onTap: () => context.push('/duel'),
                    ),
                    const SizedBox(height: 14),
                    _ModeCard(
                      icon: '🔢',
                      title: 'Classic',
                      subtitle: 'Counts only · No letter hints · Harder',
                      color: const Color(0xFFE67E22),
                      delay: 400,
                      onTap: () => context.push('/classic'),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),

              // Bottom icon bar
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _BottomIconBtn(
                      icon: Icons.bar_chart_rounded,
                      label: 'Stats',
                      onTap: () => context.push('/stats'),
                    ),
                    _BottomIconBtn(
                      icon: Icons.settings_rounded,
                      label: 'Settings',
                      onTap: () => context.push('/settings'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColoredMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const letters = 'MARK';
    const colors = [
      AppColors.correct,
      AppColors.present,
      AppColors.absent,
      AppColors.correct,
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        return Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          color: colors[i],
          child: Center(
            child: Text(
              letters[i],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final int delay;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1A1A1B),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2C2C2E)),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey[500],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: color, size: 22),
            ],
          ),
        ),
      ),
    )
        .animate(delay: delay.ms)
        .fade(duration: 300.ms)
        .slideX(begin: 0.08, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }
}

class _BottomIconBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomIconBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.grey[500], size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
