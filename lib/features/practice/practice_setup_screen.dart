import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_theme.dart';
import '../../core/models/game_config_model.dart';
import '../../core/services/word_service.dart';
import '../../core/widgets/max_width_view.dart';

class PracticeSetupScreen extends StatefulWidget {
  const PracticeSetupScreen({super.key});

  @override
  State<PracticeSetupScreen> createState() => _PracticeSetupScreenState();
}

class _PracticeSetupScreenState extends State<PracticeSetupScreen> {
  int _selectedLength = 5;

  void _startGame() {
    final word = WordService.getRandomWord(_selectedLength);
    context.push(
      '/practice/game',
      extra: GameConfig(
        mode: GameMode.practice,
        wordLength: _selectedLength,
        targetWord: word,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PRACTICE'),
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
                'How many letters?',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ).animate().fade(duration: 300.ms),
              const SizedBox(height: 8),
              Text(
                'Unlimited random words · Practice anytime',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ).animate(delay: 100.ms).fade(duration: 300.ms),
              const SizedBox(height: 40),
              Row(
                children: List.generate(4, (i) {
                  final len = i + 3;
                  final selected = len == _selectedLength;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 3 ? 12 : 0),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedLength = len),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 90,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.correct
                                : const Color(0xFF1A1A1B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? AppColors.correct
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
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'letters',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: selected
                                      ? Colors.white.withOpacity(0.8)
                                      : Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ).animate(delay: 150.ms).fade(duration: 300.ms),
              const SizedBox(height: 32),

              // Preview grid
              _GridPreview(length: _selectedLength),

              const Spacer(),
              FilledButton(
                onPressed: _startGame,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.correct,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Start Game',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ).animate(delay: 200.ms).fade(duration: 300.ms),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridPreview extends StatelessWidget {
  final int length;

  const _GridPreview({required this.length});

  @override
  Widget build(BuildContext context) {
    final maxGuesses = length == 3
        ? 6
        : length == 4
            ? 7
            : length == 5
                ? 8
                : 9;

    return Column(
      children: [
        Text(
          '${maxGuesses} guesses to find a ${length}-letter word',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[500]),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(length, (i) {
            return Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.emptyBorder, width: 2),
              ),
            );
          }),
        ),
      ],
    );
  }
}
