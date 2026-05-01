import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';
import '../../core/models/game_config_model.dart';
import '../../core/services/word_service.dart';
import '../../core/widgets/max_width_view.dart';

class ClassicHomeScreen extends StatefulWidget {
  const ClassicHomeScreen({super.key});

  @override
  State<ClassicHomeScreen> createState() => _ClassicHomeScreenState();
}

class _ClassicHomeScreenState extends State<ClassicHomeScreen> {
  int _selectedLength = 5;

  void _startSolo() {
    final word = WordService.getRandomWord(_selectedLength);
    context.push(
      '/classic/game',
      extra: GameConfig(
        mode: GameMode.classic,
        wordLength: _selectedLength,
        targetWord: word,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CLASSIC'),
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
              // Header
              Text(
                '🔢',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 56),
              ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
              const SizedBox(height: 16),
              Text(
                'Classic Mode',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No per-letter colors — just counts.\nHow many correct, present, or absent?',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[400],
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),

              // Example row
              _ExampleRow().animate(delay: 150.ms).fade(duration: 300.ms),
              const SizedBox(height: 32),

              // Word length picker
              Text(
                'Word length',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(4, (i) {
                  final len = i + 3;
                  final selected = len == _selectedLength;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 3 ? 10 : 0),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedLength = len),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 72,
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFFE67E22).withOpacity(0.15)
                                : const Color(0xFF1A1A1B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFFE67E22)
                                  : const Color(0xFF3A3A3C),
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$len',
                                style: GoogleFonts.inter(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'L',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: selected
                                      ? const Color(0xFFE67E22)
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ).animate(delay: 200.ms).fade(duration: 300.ms),

              const Spacer(),

              // Solo button
              FilledButton(
                onPressed: _startSolo,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE67E22),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Play Solo',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ).animate(delay: 250.ms).fade(duration: 300.ms),
              const SizedBox(height: 12),

              // Online section
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.push(
                          '/classic/online/create?length=$_selectedLength'),
                      style: OutlinedButton.styleFrom(
                        side:
                            const BorderSide(color: Color(0xFF3A3A3C)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        '⚔️  Online',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          context.push('/classic/online/join'),
                      style: OutlinedButton.styleFrom(
                        side:
                            const BorderSide(color: Color(0xFF3A3A3C)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Join Code',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate(delay: 300.ms).fade(duration: 300.ms),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExampleRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A3A3C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Example — guessing "CRANE":',
            style: GoogleFonts.inter(
                fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...'QUEST'.split('').map((l) => _tile(l)),
              const SizedBox(width: 10),
              _countBox(0, AppColors.correct),
              const SizedBox(width: 4),
              _countBox(2, AppColors.present),
              const SizedBox(width: 4),
              _countBox(3, const Color(0xFFE74C3C)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '0 right position · 2 in word · 3 not in word',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _tile(String letter) => Container(
        width: 34,
        height: 34,
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3C),
          border: Border.all(color: const Color(0xFF3A3A3C)),
        ),
        child: Center(
          child: Text(
            letter,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ),
      );

  Widget _countBox(int n, Color color) => Container(
        width: 28,
        height: 28,
        color: color,
        child: Center(
          child: Text(
            '$n',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ),
      );
}
