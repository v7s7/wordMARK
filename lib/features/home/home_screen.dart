import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              // Logo
              Text(
                'WORD',
                style: GoogleFonts.inter(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 8,
                ),
              )
                  .animate()
                  .fade(duration: 500.ms)
                  .slideY(begin: -0.3, end: 0, duration: 500.ms),
              _LogoMark()
                  .animate(delay: 200.ms)
                  .fade(duration: 400.ms),
              const SizedBox(height: 48),

              // Mode cards
              Expanded(
                child: ListView(
                  children: [
                    _ModeCard(
                      icon: '📅',
                      title: 'Daily Challenge',
                      subtitle: 'One word per day · All players, same word',
                      color: AppColors.correct,
                      delay: 100,
                      onTap: () => context.push('/daily'),
                    ),
                    const SizedBox(height: 16),
                    _ModeCard(
                      icon: '🎯',
                      title: 'Practice',
                      subtitle: 'Unlimited games · Random words',
                      color: AppColors.present,
                      delay: 200,
                      onTap: () => context.push('/practice'),
                    ),
                    const SizedBox(height: 16),
                    _ModeCard(
                      icon: '🧩',
                      title: 'Puzzles',
                      subtitle: 'Themed word packs · 5 free per pack',
                      color: const Color(0xFF6B5CE7),
                      delay: 300,
                      onTap: () => context.push('/puzzles'),
                    ),
                    const SizedBox(height: 16),
                    _ModeCard(
                      icon: '⚔️',
                      title: 'Duel a Friend',
                      subtitle: 'Real-time · Choose a word for them',
                      color: const Color(0xFFE74C3C),
                      delay: 400,
                      onTap: () => context.push('/duel'),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),

              // Bottom bar
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _IconBtn(
                      icon: Icons.bar_chart,
                      onTap: () => context.push('/stats'),
                    ),
                    _IconBtn(
                      icon: Icons.settings,
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

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.correct,
      AppColors.present,
      AppColors.absent,
      AppColors.correct,
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        return Container(
          width: 28,
          height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          color: colors[i],
          child: Center(
            child: Text(
              'MARK'[i],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
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
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3A3A3C)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
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
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color, size: 24),
            ],
          ),
        ),
      ),
    )
        .animate(delay: delay.ms)
        .fade(duration: 350.ms)
        .slideX(begin: 0.1, end: 0, duration: 350.ms);
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.grey[500], size: 26),
      onPressed: onTap,
    );
  }
}
